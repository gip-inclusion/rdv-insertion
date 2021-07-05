import Swal from "sweetalert2";

export default class Applicant {
  constructor(attributes, departmentNumber) {
    const formattedAttributes = {};
    Object.keys(attributes).forEach((key) => {
      formattedAttributes[key] = attributes[key].toString().trim();
    });
    this.address = formattedAttributes.address;
    this.lastName = formattedAttributes.lastName;
    this.firstName = formattedAttributes.firstName;
    this.email = formattedAttributes.email;
    this.birthDate = formattedAttributes.birthDate;
    this.birthName = formattedAttributes.birthName;
    this.city = formattedAttributes.city;
    this.postalCode = formattedAttributes.postalCode;
    this.affiliationNumber = formattedAttributes.affiliationNumber;
    this.phoneNumber = formattedAttributes.phoneNumber;
    this.role = formattedAttributes.role.toLowerCase();
    this.departmentNumber = departmentNumber;
  }

  get id() {
    return `${this.departmentNumber} - ${this.affiliationNumber} - ${this.role}`;
  }

  get uid() {
    return this.generateUid();
  }

  get createdAt() {
    return this._createdAt;
  }

  get invitedAt() {
    return this._invitedAt;
  }

  set createdAt(createdAt) {
    this._createdAt = createdAt;
  }

  set invitedAt(invitedAt) {
    this._invitedAt = invitedAt;
  }

  addRdvSolidaritesData(user) {
    this.createdAt = user.created_at;
    this.invitedAt = user.invited_at;
  }

  fullAddress() {
    return `${this.address} - ${this.postalCode} - ${this.city}`;
  }

  callToAction() {
    return this.createdAt ? "INVITER" : "CREER COMPTE";
  }

  loadingAction() {
    switch (this.callToAction()) {
      case "INVITER":
        return "INVITATION...";
      case "CREER COMPTE":
        return "CREATION...";
      default:
        return "...";
    }
  }

  generateUid() {
    // Base64 encoded "departmentNumber - affiliationNumber - role"

    const attributeIsMissing = [this.affiliationNumber, this.role].some(
      (attribute) => !attribute
    );
    if (attributeIsMissing) {
      Swal.fire(
        "Le numéro d'allocataire et le rôle doivent être renseignés pour créer un utilisateur",
        "",
        "error"
      );
      return null;
    }
    return btoa(this.id);
  }

  asJson() {
    return {
      uid: this.generateUid(),
      address: this.fullAddress(),
      last_name: this.lastName,
      first_name: this.firstName,
      email: this.email,
      birth_date: this.birthDate,
      birth_name: this.birthName,
      affiliation_number: this.affiliationNumber,
      role: this.role,
      phone_number: this.phoneNumber,
    };
  }
}
