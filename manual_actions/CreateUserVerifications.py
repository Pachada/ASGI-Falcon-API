# Crear la verificación de todos los usuarios 
from models.UserVerification import UserVerification, User, and_


def get_users_that_not_have_a_user_verification():  # sourcery skip: none-compare
    return User.get_all(and_(UserVerification.created == None), 
            join=(UserVerification,), left_join=True)


users = get_users_that_not_have_a_user_verification()
for user in users:
    user_verification = UserVerification(
            user_id = user.id
        )
    
    if not user_verification.save():
        print(f"Error usuario: {user}")


print(len(get_users_that_not_have_a_user_verification()))