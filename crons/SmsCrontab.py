import configparser
from models.SmsSent import SmsSent, or_
from models.SmsPool import SmsPool, User, Status
from core.classes.NotificationCronsUtils import NotificationCronsUtils, Utils
from core.classes.aws.SnsHandler import SnsHandler


class SmsCrontab(NotificationCronsUtils):

    __instance = None
    max_send_attempts = 3
    sms_sended = []

    @staticmethod
    def get_instance():
        return SmsCrontab.__instance or SmsCrontab()

    def __init__(self):
        if SmsCrontab.__instance is not None:
            return SmsCrontab.__instance

        SmsCrontab.__instance = self
        self.config = configparser.ConfigParser()
        self.config.read(Utils.get_config_ini_file_path())
        self.client = SnsHandler(self.config.get("SNS", "region"))

    async def send_sms(self, query_limit: int):
        sms_to_send = []
        try:
            sms_to_send = self.get_rows_to_send(SmsPool, query_limit)

            if not sms_to_send:
                self.nothing_to_send()
                return

            self.put_rows_in_proccesing_status(sms_to_send)

            errors = sum(self.__send_messages(sms_pool) for sms_pool in sms_to_send)
            # Guardamos los emails
            await SmsPool.save_all(sms_to_send)
            # Guardamos los emails enviados
            await SmsSent.save_all(self.sms_sended)
            # Borramos los enviados y que el su send_attemps sea mayor a 3
            await self.__delete_sended_and_with_errors()

            self.show_results(len(sms_to_send), errors)

        except Exception as exc:
            print(exc)
            print("Error sending sms")
            if sms_to_send:
                for sms in sms_to_send:
                    self.row_with_errors(sms)

    def __save_to_sended(self, sms_pool: SmsPool, user: User):

        sms = SmsSent(
            user_id=user.id,
            template_id=sms_pool.template_id,
            message=sms_pool.message
        )
        # Lo agregamos a los sms_sended para guardarlo posteriormente
        self.sms_sended.append(sms)

    def __send_messages(self, sms_pool: SmsPool):
        """
        Send the sms
        Returs 1 if there was an error, 0 otherwise
        """
        user: User = sms_pool.user
        error = not Utils.check_if_valid_ten_digits_number(user.phone)

        if not error:
            # If the sms was sended with out errors it will return an id, None otherwise
            sms_id = self.client.publish_text_message(user.phone, sms_pool.message)
            if not sms_id:
                error = True

        if error:
            self.row_with_errors(sms_pool)
            return 1

        # The sms was sended, save it to the sended records and delete the SmsPool object
        self.__save_to_sended(sms_pool, user)
        
        # Mark the email_pool as sended
        sms_pool.status_id = Status.SEND

        return 0

    async def __delete_sended_and_with_errors(self):
        await SmsPool.delete_multiple(or_(SmsPool.status_id == Status.SEND, SmsPool.send_attemps >= self.max_send_attempts))

    async def main(self, query_limit):
        await self.send_sms(query_limit)


if __name__ == "__main__":
    client = SmsCrontab.get_instance()
    client.main(5000)
