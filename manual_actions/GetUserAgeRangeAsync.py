from typing import List
from models.User import User, db_session
import time
import asyncio

# Sacar datos por edad:
# Rangos: 18-25, 26-30, 31-40, 41...
RANGES = [[18,25], [26,30], [31,40], [41,100], [0, None]]

async def get_age_range(users: List[User], age_start: int = 18, age_end: int = 25) -> int:
    age_range = range(age_start, age_end) if age_end else {age_start, None}
    users_in_range =  await asyncio.gather(*[user_in_age_range(user, age_range) for user in users])
    return [user for user, user_in_range in zip(users, users_in_range) if user_in_range]

async def user_in_age_range(user: User, age_range: set) -> bool:
    return user.age in age_range

async def main():
    start = time.time()
    async with db_session() as session:
        async with session.begin():
            users: List[User] = await User.get_all(session, options=User.person)
            user_in_ranges = await asyncio.gather(*[get_age_range(users, item[0], item[1]) for item in RANGES])
            ranges = {"usuarios_totales": len(users), "rangos": {f"{values[0]}-{values[1]}": len(users_in_range) for values, users_in_range in zip(RANGES, user_in_ranges)}}
            print(ranges)
            # end time
            end = time.time()
            # total time taken
            print(f"Runtime of the program is {(end - start):.2f} seconds")

if __name__ == "__main__":
    asyncio.run(main())