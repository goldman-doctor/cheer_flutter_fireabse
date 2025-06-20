class CustomUserMetadata {
  String? creationTime;
  String? lastSignInTime;

  CustomUserMetadata({this.creationTime, this.lastSignInTime});
}

class CustomUserInfo {
  String? displayName;
  String? email;
  String? phoneNumber;
  String? photoURL;
  String? providerId;

  CustomUserInfo({
    this.displayName,
    this.email,
    this.phoneNumber,
    this.photoURL,
    this.providerId,
  });
}
