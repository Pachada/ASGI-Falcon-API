from typing import List
from models.User import User, db_session
import time

# Sacar datos por edad:
# Rangos: 18-25, 26-30, 31-40, 41...


def get_age_range(users: List[User], age_start: int = 18, age_end: int = 25) -> int:
    age_range = range(age_start, age_end) if age_end else {age_start, None}
    return [user for user in users if user_in_age_range(user, age_range)]

def user_in_age_range(user: User, age_range: set) -> bool:
    return user.age in age_range

async def main():
    start = time.time()
    async with db_session() as session:
        async with session.begin():
            users: List[User] = User.get_all(session, options=User.person)
            print(len(users))
            ranges = {
                "total_users": len(users),
                "18-25": len(get_age_range(users, 18, 25)),
                "26-30": len(get_age_range(users, 26, 30)),
                "31-40": len(get_age_range(users, 31, 40)),
                "41+": len(get_age_range(users, 41, 100)),
                "no_data": len(get_age_range(users, 0, None))
            }
            print(ranges)
    # end time
    end = time.time()
    # total time taken
    print(f"Runtime of the program is {(end - start):.2f} seconds")


if __name__ == "__main__":
    main()
