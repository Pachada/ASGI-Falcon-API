from functools import cached_property
from core.Async_Model import *
from models.Role import Role
from models.Person import Person


class User(Base, AsyncModel):
    __tablename__ = "user"

    age = 0

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    username = Column(String(100), nullable=False)
    password = Column(String(300), nullable=False)
    salt = Column(String(6), nullable=False)
    email = Column(String(100), nullable=False)
    phone = Column(String(15), default=None)
    role_id = Column(BigInteger, ForeignKey(Role.id), default=Role.USER)
    person_id = Column(BigInteger, ForeignKey(Person.id))
    created = Column(DateTime, server_default=func.now())
    updated = Column(DateTime, server_default=func.now(), onupdate=func.now())
    enable = Column(Boolean, default=True)

    # Verifications
    verified = Column(Boolean, default=False)
    email_confirmed = Column(Boolean, default=False)
    phone_confirmed = Column(Boolean, default=False)

    role = relationship(Role)
    person = relationship(Person)

    def __repr__(self) -> str:
        return f"{self.username}, {self.email}"
    
    @cached_property
    def age(self):
        return self.calc_age() if self.person.birthday else 0
    
    def calc_age(self) -> int:
        today = date.today()
        birthdate = self.person.birthday
        return today.year - birthdate.year - ((today.month, today.day) < (birthdate.month, birthdate.day))

    @staticmethod
    async def check_if_user_exists(db_session: AsyncSession, username, email):
        if username:
            if check_username := await User.get(db_session, User.username == username):
                return True, "This username already exists"

        if email:
            if check_email := await User.get(db_session, User.email == email):
                return True, "This email already has an account"

        return False, ""
        
