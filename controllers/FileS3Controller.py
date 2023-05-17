from core.classes.FileUtils import (
    FileController,
    FileAbstract,
    FileTypes,
    Utils,
    File,
    Request,
    Response,
)
from io import BufferedReader
import time
from core.classes.FileManager import FileManager


class FileS3Controller(FileController, FileAbstract):
    def __init__(self):
        super().__init__()
        #  AWS S3 info
        self.private_bucket = self.config.get("S3", "private_bucket_name")
        self.public_bucket = self.config.get("S3", "public_bucket_name")
        self.video_bucket = self.config.get("S3", "video_bucket_name")
        self.region = self.config.get("S3", "region")

    async def on_get(self, req: Request, resp: Response, id: int = None):
        if not id:
            self.response(resp, 405)
            return

        file, file_object = FileManager.get_file(self.private_bucket, id, self.region)

        if not file:
            self.response(resp, 404, error="No file with that id")
            return

        if not file_object:
            self.response(resp, 500, error="Error geting file from s3")
            return

        resp.set_header("content-disposition", f'inline; filename="{file.name}"')
        resp.stream = BufferedReader(file_object)
        resp.content_length = file.size
        resp.content_type = file.type

    async def on_post(self, req: Request, resp: Response, id: int = None):
        super().on_post(req, resp, id)

    async def on_delete(self, req: Request, resp: Response, id: int = None):
        if not id:
            self.response(resp, 405)
            return

        async with req.context.db_session as db_session:
            file, deleted = FileManager.delete_file(self.private_bucket, id, self.region)
            if not file:
                self.response(resp, 404, error=self.ID_NOT_FOUND)
                return

            if not deleted:
                self.response(resp, 500, error="Error deleting file from S3")
                return

            if not file.delete(db_session):
                self.response(
                    resp,
                    500,
                    error="File deleted from S3, but failed to deleted from database",
                )
                return

        self.response(resp, 200, Utils.serialize_model(file))

    # -------------------------------- base64 --------------------------------

    async def on_get_base64(self, req: Request, resp: Response, id: int = None):
        if not id:
            self.response(resp, 405)
            return

        file, file_object = FileManager.get_file(self.private_bucket, id, self.region)

        if not file:
            self.response(resp, 404, error="No file with that id")
            return

        file_content = file_object.read()
        file_object.close()
        file_content_b64 = super().encode_to_base64(file_content)
        data = Utils.serialize_model(file)
        data["base64"] = str(file_content_b64)[2:-1]

        self.response(resp, 200, data)

    # -------------------------------- Utils --------------------------------

    def create_file(self, file_name, file_content, file_type, is_thumbnail=0, encode_to_base64=False, public=False):
        file_content = super().format_file_content(file_content)

        hash_string = file_name + file_type + str(time.time()) + str(file_content)[:25]
        file_hash = Utils.get_hashed_string(hash_string)

        if encode_to_base64:
            file_content = super().encode_to_base64(file_content)

        bucket = self.private_bucket
        is_video: bool = file_type == FileTypes.VIDEO.value
        if is_video:
            bucket = self.video_bucket
        elif public:
            bucket = self.public_bucket

        # https://inmobiliaria-files.s3.amazonaws.com/6d9860c300a8744cbbf3f5.png
        url = f"https://{bucket}.s3.amazonaws.com/{file_hash}" if public or is_video else None

        return FileManager.put_file(
            bucket,
            file_content,
            file_hash,
            file_type=file_type,
            file_name=file_name,
            region=self.region,
            is_thumbnail=is_thumbnail,
            url=url
        )
