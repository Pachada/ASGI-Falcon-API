import json
from models.User import User, datetime
from models.PushNotificationTemplate import PushNotificationTemplate, PushNotificationCatalogue
from models.PushNotificationPool import PushNotificationPool
#from crons.ExpoPushNotificationCrontab import ExpoPushNotificationCrontab
from crons.OneSignalPushNotificationCrontab import OneSignalPushNotificationCrontab


class PushNotificationClient:
    
    @staticmethod
    def send_notification_to_pool(template_id: int, user = None, data: dict = None, extra: dict = None, send_time: datetime = datetime.utcnow(), send_now=False):
        """
        Gives format to the message to send and save it to the push pool.
        If the push is meant to ALL users, the user parameters should be None,
        but if the push is only for a group, user should be a list of users

        Parameters
        ----------
        template_id  :  `int`
                id of the PushNotificationTemplate.
        user  :  `None`,`User`,`list`
                A User or a list of Users to send the push to.
                None if the target is all users.
        data  :  `dict`
                The data to be replace in the PushTemplate.
        extra  :  `dict`
                The extra data to be added to the Push. 
        send_time  :  `datetime`
                The UTC time to send the push, utcnow() by default.
        send_now  :  `bool`
                If the push should be process/sended right away.
                False by default.
                
        Returns
        ----------
        `None`
        """
        if data is None:
            data = {}
        if extra is None:
            extra = {}
        template = PushNotificationTemplate.get(template_id)
        message = PushNotificationClient.__format_message(template, data)

        if isinstance(user, list):
            for item in user:
                PushNotificationClient.__save_to_pool(template, message, send_time, extra, item)
            return

        PushNotificationClient.__save_to_pool(template, message, send_time, extra, user)

        if send_now and send_time <= datetime.utcnow():
            #client = ExpoPushNotificationCrontab.get_instance()
            client = OneSignalPushNotificationCrontab.get_instance() 
            client.procces_pool()

    @staticmethod
    def __format_message(template: PushNotificationTemplate, data: dict):
        message = f"{template.title}\n{template.message}"
        for key in data:
            message = message.replace(
                "{{" + key + "}}", data[key]
            )
        
        return message
    
    @staticmethod
    def __save_to_pool(template: PushNotificationTemplate, message: str, send_time: datetime, extra: dict = None, user = None):
        if extra is None:
            extra = {}
        push_notification = PushNotificationPool(
            user_id=user.id if user else None,
            template_id=template.id,
            message=message,
            send_time=send_time
        )

        catalogue: PushNotificationCatalogue = template.catalogue
        if catalogue:
            extra["action"] = catalogue.action
            push_notification.data = json.dumps(extra)

        push_notification.save()
