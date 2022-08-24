from sqlalchemy import (
    Column,
    Integer,
    String,
    BigInteger,
    ForeignKey,
    DateTime,
    Date,
    Text,
    Float,
    CHAR,
    SmallInteger,
    Boolean,
    func,
    distinct,
    or_,
    and_,
    case
)
from sqlalchemy.orm import relationship, exc, selectinload, lazyload, joinedload
from sqlalchemy.sql import func
from sqlalchemy.dialects import mysql
from sqlalchemy.orm.util import was_deleted, has_identity
from datetime import datetime, date
from core.database import Base, engine, get_db_session
from core.Utils import Utils, logger
from sqlalchemy import update
from sqlalchemy.future import select
from sqlalchemy.ext.asyncio import AsyncSession as DB_Session
from sqlalchemy.sql.expression import Select


class AsyncModel:

    __mapper_args__ = {"eager_defaults": True}

    """
    The Model Class has methods to process queries in database in a easily way like
    get one, get all, delete and save. The Model class inherits new models.
    """

    def refresh_object(self, db_session: DB_Session, attribute_names=None):
        db_session.refresh(self, attribute_names)

    def get_formatters(self):
        return {attribute.name: Utils.date_formatter for attribute in self.__table__.columns if attribute.type.python_type in {datetime, date}}

    async def exists_in_database(self, db_session: DB_Session):
        """
        Return True if the object exists in database, False otherwise.
        """
        try:
            row = await self.get(db_session, self.id)
            return row and not was_deleted(self) and has_identity(self)
        except exc.ObjectDeletedError:
            return False

    def get_files(self):
        """
        Returns a list with the file objects of a Model subclass
        """
        return [
            getattr(self, relation)
            for relation in self.__mapper__.relationships.keys()
            if "file" in relation
        ]

    def delete_model_files(self, req, resp, s3_file=True, local_file=False):
        """
        The  delete_model_files() delete the files asociated to a model instance using the FileS3Controller
        or the FileLocalController on_delete methods, witch requiere the req and resp.
        Be carefull; if the relatonship with the model is in Cascade, it will delete the row.
        """
        for file in self.get_files():
            if not file:
                continue
            if s3_file:
                file.delete_file_from_s3(req, resp)
            elif local_file:
                file.delete_file_from_local()

    @classmethod
    async def get(cls, db_session: DB_Session, value, get_relationtships=True, deleted=False, join=None, order_by=None):
        """
        The get() method can process a query with some parameters to get a response.

        Parameters
        ----------
        value  :  `int`,`str`
                A parameter to filter by.
        filter  :  `expr`
                A parameter to filter.
        deleted  :  `bool`
                False by default.
        join : `Model`
            A list of model to join the query with. None by default.
        order_by : `expr`
                None by default.
        with_for_update  :  `bool`
                False by default.

        Returns
        ----------
        `object`
            An object with query results."""
        query: Select = select(cls)
        if get_relationtships:
            query = query.options(selectinload('*'))
        if join:
            if isinstance(join, list):
                for model in join:
                    query = query.join(model)
            else:
                query = query.join(join)
        if not deleted and "enable" in cls.__table__.columns.keys():
            query = query.where(cls.enable == 1)
        if isinstance(value, int):
            query = query.where(cls.id == value)
        else:
            query = query.where(value)
        if order_by is not None:
            query = query.order_by(order_by)

        result = await db_session.execute(query)
        return result.scalars().first()

    @classmethod
    async def get_all(cls, session: DB_Session, get_relationtships=True, limit=None, orderBy=None, deleted=False, join=None, left_join=False):
        """
        The get_all() method process a query and returns all found values.

        Parameters
        ----------
        filter : `str`, `int`
            A parameter to filter the query, None by default.
        limit : `int`
            Sets the query limit.
        offset : `str`
            The offset of query.
        orderBy : `str`
            Parameter to order the query.
        deleted : `bool`
            False by default.
        join : `Model`
            A list of model to join the query with. None by default.
        left_join : `bool`
            If the join should be done as left outer join. False by default.

        Returns
        -------
        `object`
            An object with all results.
        """
        query: Select = select(cls)
        if get_relationtships:
            query = query.options(selectinload('*'))
        if join:
            if isinstance(join, list):
                for model in join:
                    query = query.join(model, isouter=left_join)
            else:
                query = query.join(join, isouter=left_join)
        if not deleted and "enable" in cls.__table__.columns.keys():
            query = query.where(cls.enable == 1)
        if orderBy is not None:
            if isinstance(orderBy, list):
                for ord in orderBy:
                    query = query.order_by(ord)
            else:
                query = query.order_by(orderBy)
        if limit is not None:
            query = query.limit(limit)

        result = await session.execute(query)
        return result.scalars().all()

    async def save(self, session: DB_Session):
        try:
            session.add(self)
            await session.commit()
            return True
        except Exception as exc:
            print("[ERROR-SAVING]")
            print(exc)
            await session.rollback()
            return False

    async def soft_delete(self, session: DB_Session):
        """
        The soft_delete() method changes the status of a row in the enable column into *deleted* by changing its
        value to 0, this indicate that the row has not been deteled at all but in next queries this row will not be
        taken at least that is specify in the query.

        Returns
        -------
        `bool`
            True if enable = 0 and save() method processes successful for soft_delete(), False otherwise.
        """
        try:
            self.enable = 0
            return await self.save(session)
        except Exception as exc:
            logger.error("[ERROR-SOFT-DELETING]")
            logger.error(exc)
            return False

    async def delete(self, session: DB_Session):
        """
        The delete() method deletes a row from database, if something went wrong
        delete() can roll back changes made too.

        Returns
        -------
        `bool`
            True if delete and commit is process successful, False otherwise.
        """
        try:
            session.delete(self)
            await session.commit()
            return True
        except Exception as exc:
            await session.rollback()
            logger.error("[ERROR-DELETING]")
            logger.error(exc)
            return False

    @classmethod
    async def delete_multiple(cls, session: DB_Session, filter):
        try:
            query = cls.__table__.delete().where(filter)
            session.execute(query)
            await session.commit()
            return True
        except Exception as exc:
            logger.error("[ERROR-DELETING-MULTIPLE]")
            logger.error(exc)
            return False

    @classmethod
    async def count(cls, session: DB_Session, filter=None, deleted=False, join=None):
        """
        The count() method counts all rows depending its parameters wich can be filtered,
        deleted or make a join.

        Parameters
        ----------
        filter : `str`, `int`
            Value to filter by.
        deleted : `bool`
            False by default.
        join : `None`
            None by default.

        Returns
        -------
        `object`
            An object with count() results.
        """
        try:
            query: Select = select(cls)
            if join:
                if isinstance(join, list):
                    for model in join:
                        query = query.join(model)
                else:
                    query = query.join(join)
            if not deleted and "enable" in cls.__table__.columns.keys():
                query = query.where(cls.enable == 1)

            result = await session.execute(query)
            return result.scalars().count()
        except Exception as exc:
            logger.error("[ERROR-COUNTING]")
            logger.error(exc)
            return False

    @classmethod
    async def sum(cls, session: DB_Session, field, filter=None):
        """
        The sum() method sums all rows of a field, if there is not result then returns 0.

        Parameters
        ----------
        field : `str`
            A string for field of model.
        filter : `None`
            None by default.

        Returns
        -------
        `int`
            Sum of results.
        """
        try:
            if field and hasattr(cls, field):
                field_ = getattr(cls, field, None)
            query = session.query(func.sum(field_))
            if filter is not None:
                query = query.filter(filter)
            return query.scalar() or 0
        except Exception as exc:
            logger.error("[ERROR_ADDING]")
            logger.error(exc)
            return False

    @classmethod
    async def max(cls, session: DB_Session, field, filter=None):
        """
        The max() method process a query and returns the max value of a field.

        Parameters
        ----------
        field : `str`
            A string for field of model.
        filter : `None`
            None by default.

        Returns
        -------
        `object`
            An object with max result.
        """
        try:
            if field and hasattr(cls, field):
                field_ = getattr(cls, field, None)
            query = session.query(func.max(field_))
            if filter is not None:
                query = query.filter(filter)

            return query.scalar()
        except Exception as exc:
            logger.error("[ERROR_GETTING-MAX]")
            logger.error(exc)
            return False

    @classmethod
    async def min(cls, session: DB_Session, field, filter=None):
        """
        The min() method process a query and returns the min value of a field.

        Parameters
        ----------
        field : `str`
            A string for field of model.
        filter : `None`
            None by default.

        Returns
        -------
        `object`
            An object with min result.
        """
        try:
            if field and hasattr(cls, field):
                field_ = getattr(cls, field, None)
            query = session.query(func.min(field_))
            if filter is not None:
                query = query.filter(filter)

            return query.scalar()
        except Exception as exc:
            logger.error("[ERROR-GETTING-MIN]")
            logger.error(exc)
            return False

    @classmethod
    async def distinct(cls, session: DB_Session, field, filter=None, deleted=False):
        try:
            if field and hasattr(cls, field):
                field_ = getattr(cls, field, None)
            query = session.query(field_)
            if not deleted and "enable" in cls.__table__.columns.keys():
                query = query.filter(cls.enable == 1)
            if filter is not None:
                query = query.filter(filter)

            return query.distinct().all()
        except Exception as exc:
            logger.error(exc)
            return False

    @staticmethod
    async def save_all(session: DB_Session, instances):
        """
        The save_all() method adds more than one objects of Models and saves them to the database,
        if something went wrong save_all() can roll back changes made too.

        Parameters
        ----------
        instances : `list`
            A list of instances of model.

        Returns
        -------
        `bool`
            True if add and commit is process successful, False otherwise.
        """
        try:
            if isinstance(instances, list):
                session.add_all(instances)
                await session.commit()
            else:
                await instances.save()
            return True
        except Exception as exc:
            session.rollback()
            logger.error("[ERROR-SAVING-ALL]")
            logger.error(exc)
            return False

    @staticmethod
    async def remove(session: DB_Session, instance):
        """
        The remove() method removes an instance.

        Parameters
        ----------
        instance : `instance`
            A instance to remove.

        Returns
        -------
        `bool`
            Returns True if the instance is removed, False otherwise.
        """
        try:
            session.expunge(instance)
            return True
        except Exception as exc:
            session.rollback()
            logger.error("[ERROR-EXPUNGE]")
            logger.error(exc)
            return False
