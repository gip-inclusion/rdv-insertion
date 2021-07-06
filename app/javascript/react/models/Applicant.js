import Swal from "sweetalert2";

const ROLES = {
  dem: "demandeur",
  cjt: "conjoint",
};

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
    this.role =
      ROLES[formattedAttributes.role.toLowerCase()] || formattedAttributes.role.toLowerCase();
    this.departmentNumber = departmentNumber;
  }

  get uid() {
    return this.generateUid();
  }

  get createdAt() {
    return this._createdAt;
  }

  get invitationSentAt() {
    return this._invitationSentAt;
  }

  get id() {
    return this._id;
  }

  set createdAt(createdAt) {
    this._createdAt = createdAt;
  }

  set id(id) {
    this._id = id;
  }

  set invitationSentAt(invitatioSentAt) {
    this._invitationSentAt = invitatioSentAt;
  }

  augmentWith(augmentedApplicant) {
    this.createdAt = augmentedApplicant.created_at;
    this.invitedAt = augmentedApplicant.invited_at;
    this.id = augmentedApplicant.id;
    this.invitationSentAt = augmentedApplicant.invitation_sent_at;
  }

  fullAddress() {
    return `${this.address} - ${this.postalCode} - ${this.city}`;
  }

  callToAction() {
    if (!this.createdAt) {
      return "CREER COMPTE";
    }
    if (!this.invitationSentAt) {
      return "INVITER";
    }
    return "REINVITER";
  }

  loadingAction() {
    switch (this.callToAction()) {
      case "INVITER":
        return "INVITATION...";
      case "REINVITER":
        return "INVITATION...";
      case "CREER COMPTE":
        return "CREATION...";
      default:
        return "...";
    }
  }

  generateUid() {
    // Base64 encoded "departmentNumber - affiliationNumber - role"

    const attributeIsMissing = [this.affiliationNumber, this.role].some((attribute) => !attribute);
    if (attributeIsMissing) {
      Swal.fire(
        "Le numéro d'allocataire et le rôle doivent être renseignés pour créer un utilisateur",
        "",
        "error"
      );
      return null;
    }
    return btoa(`${this.departmentNumber} - ${this.affiliationNumber} - ${this.role}`);
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
