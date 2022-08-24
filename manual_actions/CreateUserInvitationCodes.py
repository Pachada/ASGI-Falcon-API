from models.User import User, Utils

def create_user_invitation_code(user: User):
    print(f"Creando código de: {user}")
    while True:
        user_invitation_code = Utils.generate_otp(6)
        if not User.get(User.invitation_code == user_invitation_code):
            break
    
    user.invitation_code = user_invitation_code
    user.save()

user_with_out_invitation_code = User.get_all(User.invitation_code == None)
for user in user_with_out_invitation_code:
    create_user_invitation_code(user)
