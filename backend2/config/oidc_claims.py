def userinfo(claims, user):
    """
    Populate user claims for OIDC userinfo endpoint and ID tokens.
    """
    claims['sub'] = str(user.id)
    claims['name'] = user.get_full_name() or user.username
    claims['preferred_username'] = user.username
    claims['given_name'] = user.first_name or user.username
    claims['family_name'] = user.last_name or ''
    claims['email'] = user.email or f"{user.username}@example.com"
    claims['email_verified'] = bool(user.email)
    return claims
