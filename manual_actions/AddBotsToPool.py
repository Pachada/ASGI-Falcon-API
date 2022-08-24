import csv
from random import randint, randrange
import datetime
from core.Utils import Utils, logger
from models.User import User
from core.classes.Authenticator import Authenticator, Session
from models.Pool_Match import Pool_Match, Match, Pool
from models.Tiebreaker_Rules import Tiebreaker_Rules, and_
from models.Sport import Sport
from core.classes.RequestsUtils import RequestsUtils
from models.Pool_User import Pool_User

class MexicanName():

    @staticmethod
    def __get_inegi_data(filename):
        with open(filename, "r") as data:
            reader = list(csv.reader(data, delimiter="\n"))
            return f'{reader[randint(0, len(reader))][0].split(",")[0]}'.title()
    @staticmethod
    def get_name():
        return MexicanName.__get_inegi_data("Nombres.csv")
        
    @staticmethod
    def get_last_name():
        return MexicanName.__get_inegi_data("Apellidos.csv")

    @staticmethod
    def get_full_name():
        return f"{MexicanName.get_name()} {MexicanName.get_last_name()}"

    @staticmethod
    def get_birthday():
        start_date = datetime.date(1950, 1, 1)
        end_date = datetime.date(2003, 1, 1)

        time_between_dates = end_date - start_date
        days_between_dates = time_between_dates.days
        random_number_of_days = randrange(days_between_dates)
        return start_date + datetime.timedelta(days=random_number_of_days)

    @staticmethod
    def __unite_firts_and_last_name_letters(name, last_name):
        return f'{name[:3]}{last_name[:3]}'.title()

    @staticmethod
    def __name_with_birthday(name, last_name, birthday:datetime):
        text = name if randint(0,1) == 0 else last_name
        return f'{text}{str(birthday)[2:4]}'.replace(" ", "")

    @staticmethod
    def __nickname_from_list(filename="Nicknames.txt"):
        with open(filename, "r", encoding="utf8") as data:
            lines = data.readlines()
            return lines[randint(0, len(lines))].strip()

    @staticmethod
    def generate_nickname(name, last_name, birthday=None):
        ran = randint(0,4)
        if ran == 0:
            return MexicanName.__unite_firts_and_last_name_letters(name, last_name)
        elif ran == 1 and birthday:
            return MexicanName.__name_with_birthday(name, last_name, birthday)
        elif ran == 2:
            return name
        elif ran == 3:
            return last_name
        else:
            return MexicanName.__nickname_from_list()

class Bot:

    def __init__(self, user:User=None):
        self.name = user.name if user else MexicanName.get_name()
        self.last_name = user.last_name if user else MexicanName.get_last_name()
        self.birthday = user.birthday if user else MexicanName.get_birthday()

        self.nickname = user.nickname  if user else MexicanName.generate_nickname(self.name, self.last_name, self.birthday)
        if not user:
            while User.check_if_user_exists(self.nickname):
                self.nickname = MexicanName.generate_nickname(self.name, self.last_name, self.birthday)
        
        self.email = user.email if user else f"{self.nickname}@bot.com"
        self.password = user.password if user else Utils.get_hashed_string(self.nickname)
        if not user:
            user = User(
                name = self.name,
                last_name = self.last_name, 
                birthday = self.birthday,
                nickname = self.nickname,
                email = self.email,
                password = self.password, 
                is_bot = True
            )
            user.save()
        
        self.user = user
        self.user_id = user.id 

    def __repr__(self):
        return f"{self.user.nickname}"

    def get_user(self):
        return self.user or User.get(self.user_id)
    
    def add_bot_to_pool(self, pool:Pool, pool_matchs:list=None, pool_tiebreakers:list=None):
        if not pool_matchs:
            pool_matchs = Match.getAll(
                and_(Pool_Match.pool_id == pool.id, Pool_Match.enable == 1),
                join=Pool_Match,
                orderBy=Match.start_date.asc(),
            )
        
        if not pool_tiebreakers:
            pool_tiebreakers = Tiebreaker_Rules.getAll(Tiebreaker_Rules.pool_id == pool.id)
        
        data = {
            "pool_id": pool.id,
            "picks": [],
            "tiebreakers": []
        }

        options = {
            0 : "local",
            1 : "visitor",
            2 : "tie"
        }
        # Picks aleatorios para los partidos y pregutnas
        for match in pool_matchs:
            match:Match = match
            # Seleccionando pick aleatorio, en partidos de fut hay "tie", en los demas "local" y "visitor"
            selection =  options[randint(0,1)] if match.league.sport_id == Sport.FUTBOL  else options[randint(0,2)]
            data["picks"].append(
                {
                "match_id": match.id,
                "selection": selection
                }
            )
        
        for tiebreaker in pool_tiebreakers:
            tiebreaker:Tiebreaker_Rules = tiebreaker
            data["tiebreakers"].append(
                {
                "tiebreaker_rule_id": tiebreaker.id,
                "answer": randint(0, len(tiebreaker.options.split(','))-1)
                },
            )
        
        session:Session = Authenticator.start_user_session(self.get_user())
        response, error = RequestsUtils.post_url(
            url = "http://ec2-3-135-3-188.us-east-2.compute.amazonaws.com:3000/api/pools/users", #DUEALZO DEV
            data = data,
            headers = {"Authorization": session.token},
            response_as_json = False
            
        )
        if response.status_code != 200:
            logger.warning(f"Error agregando bot: {error}")
        else:
            logger.info(f"Bot {self.nickname} agregado a {pool}")

    @staticmethod
    def get_bots_not_in_pool(pool: Pool, limit=None):  # sourcery skip: none-compare
        users =  User.get_all(
            and_(User.is_bot == True, Pool_User.created_at == None),
            join=(
                Pool_User,
                and_(Pool_User.pool_id == pool.id, Pool_User.user_id == User.id),
            ),
            left_join=True,
        )

        return [Bot(user) for user in users]
    
    @staticmethod
    def add_bots_to_pool(pool:Pool, number_of_bots=50):
        logger.info(f"Añadiendo {number_of_bots} a {pool}")
        
        bots_not_in_pool = Bot.get_bots_not_in_pool(pool, limit=number_of_bots)
        while len(bots_not_in_pool) < number_of_bots:
            bots_not_in_pool.append(Bot())
        
        pool_matches = Match.getAll(
            and_(Pool_Match.pool_id == pool.id, Pool_Match.enable == 1),
            join=Pool_Match,
            orderBy=Match.start_date.asc(),
        )

        pool_tiebreakers = Tiebreaker_Rules.getAll(Tiebreaker_Rules.pool_id == pool.id)
        
        for bot in bots_not_in_pool:
            bot : Bot = bot
            bot.add_bot_to_pool(pool, pool_matches, pool_tiebreakers)


if __name__ == "__main__":
    print("Agregar bots a una quiniela")
    print("Seleccione la quiniela: ")
    pools = Pool.getAll(orderBy=Pool.limit_date.desc(), limit=3)
    for i, pool in enumerate(pools):
        print(f"{i+1}. {pool}")
    option = int(input())
    selected_pool = pools[option-1]
    print(f"Cuantos bots quieres agregar a a quiniela {selected_pool}?")
    number_of_bots = int(input())
    Bot.add_bots_to_pool(selected_pool, number_of_bots)
