from core.classes.PoolUtils import PoolUtils, Pool, Match, and_, Pool_Match, Pool_User, Picks, Tiebreaker_Rules, Tiebreaker
import asyncio
import time


async def qualify_picks(pool_user: Pool_User, matches_count: int):
    if not matches_count:
        return 0

    picks = Picks.getAll(
        and_(
            Picks.user_id == pool_user.user_id,
            Picks.pool_id == pool_user.pool_id,
            Match.result != None
        ),
        join=Match
    )

    score = 0
    # revizamos si los picks que hicieron son correctos
    # Si lo son, le sumamos +1 a su score
    if picks:
        for pick in picks:
            pick: Picks = pick
            if pick.selection == pick.match.result:
                score += 1

    return score

async def qualify_tiebreakers(pool_user: Pool_User, matches_count: int):
        tb_point = 0.1 if matches_count else 1

        tiebreakers = Tiebreaker.getAll(
            and_(
                Tiebreaker_Rules.answer != None,
                Tiebreaker.pool_id == pool_user.pool_id,
                Tiebreaker.user_id == pool_user.user_id,
                Tiebreaker.answer != None,
            ),
            join=Tiebreaker_Rules,
        )
        score = 0
        if tiebreakers:
            for tiebreaker in tiebreakers:
                tiebreaker: Tiebreaker = tiebreaker
                if int(tiebreaker.answer) == int(tiebreaker.tiebreaker_rule.answer):
                    score += tb_point
        return score

async def foo(pool_user: Pool_User, matches_count: int):
    score = 0
    # Revizamos los picks
    score += await qualify_picks(pool_user, matches_count)

    # Revizamos los tiebreakers
    score += await qualify_tiebreakers(pool_user, matches_count)

    # Si es un bot le restamos puntos
    if pool_user.user.is_bot:
        score -= 2
        score = max(score, 0)
        
    pool_user.score = score

async def qualify_pool(pool):
    if isinstance(pool, list):
        for item in pool:
            PoolUtils.qualify_pool(item)
        return

    if isinstance(pool, Pool):
        print(f"Actualizando scores de la quinela {pool.title}")
        matches_count = len(Match.getAll(
            and_(
                Pool_Match.pool_id == pool.id,
                Pool_Match.enable == 1
            ),
            join=Pool_Match
        ))

        pool_users = Pool_User.getAll(Pool_User.pool_id == pool.id)
        if not pool_users:
            return

        await asyncio.gather(*[foo(pool_user, matches_count) for pool_user in pool_users])

        #Pool_User.saveAll(pool_users)
        print(f"Se termino de actualizar la pool {pool.title}")


async def main():
    start = time.time()
    if pool := Pool.get(478):
        await qualify_pool(pool)
    
    # end time
    end = time.time()
    # total time taken
    print(f"Runtime of the program is {(end - start):.2f} seconds")


if __name__ == "__main__":
    asyncio.run(main())