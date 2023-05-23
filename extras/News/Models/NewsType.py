from core.AsyncModel import *
from core.Utils import Utils


class NewsType(Base, AsyncModel):
    # New Types
    RECORDATORIO = 1
    AVISO = 2
    COMUNICADO_GENERAL = 3
    URGENTE = 4
    DATOS_CURISOSO = 5

    __tablename__ = "news_types"
    

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    type = Column(String(50), nullable=False)
    enable = Column(Boolean, nullable=False, default=1)
