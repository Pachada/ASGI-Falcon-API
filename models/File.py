from core.Async_Model import *


class File(Base, AsyncModel):
    __tablename__ = "file"
    

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    object = Column(String(255), nullable=False)
    size = Column(Integer, nullable=False)
    type = Column(String(255), nullable=False)
    name = Column(String(255), nullable=False)
    hash = Column(String(255), nullable=False)
    is_thumbnail = Column(mysql.TINYINT(1), default=0)
    url = Column(String(255), default=None)
    created = Column(DateTime, default=func.now())
    updated = Column(DateTime, default=func.now(), onupdate=func.now())
    enable = Column(Boolean, default=True)


    def delete_file_from_s3(self, req, resp):
        # sourcery skip: class-extract-method
        print(f"Borrando file: {self.id} del s3")
        from controllers import files3Controller

        files3Controller.on_delete(req, resp, self.id)

    def delete_file_from_local(self, req, resp):
        print(f"Borrando file: {self.id} del local")
        from controllers import filelocalController

        filelocalController.on_delete(req, resp, self.id)
