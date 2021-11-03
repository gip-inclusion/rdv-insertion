import formatPhoneNumber from "../../lib/formatPhoneNumber";

const ROLES = {
  dem: "demandeur",
  cjt: "conjoint",
};

const TITLES = {
  mr: "monsieur",
  mme: "madame",
};

export default class Applicant {
  constructor(attributes, departmentNumber, organisationConfiguration) {
    const formattedAttributes = {};
    Object.keys(attributes).forEach((key) => {
      formattedAttributes[key] = attributes[key]?.toString()?.trim();
    });
    this.address = formattedAttributes.address;
    this.lastName = formattedAttributes.lastName;
    this.firstName = formattedAttributes.firstName;
    this.title =
      TITLES[formattedAttributes.title?.toLowerCase()] || formattedAttributes.title?.toLowerCase();
    this.email = formattedAttributes.email;
    this.birthDate = formattedAttributes.birthDate;
    this.birthName = formattedAttributes.birthName;
    this.city = formattedAttributes.city;
    this.postalCode = formattedAttributes.postalCode;
    this.fullAddress = formattedAttributes.fullAddress || this.formatAddress();
    this.customId = formattedAttributes.customId;
    this.affiliationNumber = this.formatAffiliationNumber(formattedAttributes.affiliationNumber);
    this.phoneNumber = formatPhoneNumber(formattedAttributes.phoneNumber);
    // CONJOINT/CONCUBIN/PACSE => conjoint
    const formattedRole = formattedAttributes.role?.split("/")?.shift()?.toLowerCase();
    this.role = ROLES[formattedRole] || formattedRole;
    this.departmentNumber = departmentNumber;
    this.organisationConfiguration = organisationConfiguration;
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

  set invitationSentAt(invitationSentAt) {
    this._invitationSentAt = invitationSentAt;
  }

  formatAffiliationNumber(affiliationNumber) {
    if (affiliationNumber && [13, 15].includes(affiliationNumber.length)) {
      // This means it is a NIR, we replace it by a custom ID if present
      if (this.customId) {
        return `CUS-${this.customId}`;
      }
      return null;
    }
    return affiliationNumber;
  }

  updateWith(upToDateApplicant) {
    // we update the attributes if they are different in the app than in the file
    this.firstName = upToDateApplicant.first_name;
    this.lastName = upToDateApplicant.last_name;
    this.email = upToDateApplicant.email;
    this.phoneNumber = formatPhoneNumber(upToDateApplicant.phone_number_formatted);
    this.fullAddress = upToDateApplicant.address;
    this.createdAt = upToDateApplicant.created_at;
    this.invitedAt = upToDateApplicant.invited_at;
    this.id = upToDateApplicant.id;
    this.invitationSentAt = upToDateApplicant.invitation_sent_at;
  }

  formatAddress() {
    return (
      (this.address ?? "") +
      (this.postalCode ? ` - ${this.postalCode}` : "") +
      (this.city ? ` - ${this.city}` : "")
    );
  }

  shouldDisplay(attribute) {
    return this.organisationConfiguration.column_names[attribute];
  }

  callToAction() {
    if (!this.createdAt) {
      return "CREER COMPTE";
    }
    if (!this.shouldBeInvited()) {
      return null;
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

  shouldBeInvited() {
    return this.organisationConfiguration.invitation_format !== "no_invitation";
  }

  hasMissingAttributes() {
    return [this.firstName, this.lastName, this.title].some((attribute) => !attribute);
  }

  generateUid() {
    // Base64 encoded "departmentNumber - affiliationNumber - role"

    const attributeIsMissing = [this.affiliationNumber, this.role].some((attribute) => !attribute);
    if (attributeIsMissing) {
      return null;
    }
    return btoa(`${this.departmentNumber} - ${this.affiliationNumber} - ${this.role}`);
  }

  asJson() {
    return {
      uid: this.generateUid(),
      address: this.fullAddress,
      title: this.title,
      last_name: this.lastName,
      first_name: this.firstName,
      role: this.role,
      affiliation_number: this.affiliationNumber,
      ...(this.phoneNumber && { phone_number: this.phoneNumber }),
      ...(this.email && this.email.includes("@") && { email: this.email }),
      ...(this.birthDate && { birth_date: this.birthDate }),
      ...(this.birthName && { birth_name: this.birthName }),
      ...(this.customId && { custom_id: this.customId }),
    };
  }
}
