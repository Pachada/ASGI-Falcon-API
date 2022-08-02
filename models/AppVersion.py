from core.Model import *


class AppVersion(Base, Model):
    __tablename__ = "app_version"
    

    id = Column(Integer, primary_key=True, autoincrement=True)
    version = Column(Float, nullable=False)
    created = Column(DateTime, default=Utils.time())

    @staticmethod
    def get_actual_version() -> float:
        return AppVersion.max("version")

    @staticmethod
    def get_actual_version_class():
        return AppVersion.get(AppVersion.max("id"))
    
    def __repr__(self) -> str:
        return f"version {self.version}"

    def __eq__(self, other: object) -> bool:
        if self.id == other.id and self.version == other.version and self.created == other.created:
            return True
            