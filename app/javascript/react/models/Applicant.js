import Swal from "sweetalert2";
import formatPhoneNumber from "../lib/formatPhoneNumber";
import retrieveLastInvitationDate from "../lib/retrieveLastInvitationDate";

const ROLES = {
  dem: "demandeur",
  cjt: "conjoint",
};

const TITLES = {
  mr: "monsieur",
  mme: "madame",
};

export default class Applicant {
  constructor(attributes, departmentNumber, departmentConfiguration) {
    const formattedAttributes = {};
    Object.keys(attributes).forEach((key) => {
      formattedAttributes[key] = attributes[key]?.toString()?.trim();
    });
    this.address = formattedAttributes.address;
    this.lastName = formattedAttributes.lastName;
    this.firstName = formattedAttributes.firstName;
    this.title =
      TITLES[formattedAttributes.title?.toLowerCase()] || formattedAttributes.title?.toLowerCase();
    this.shortTitle = (this.title === "monsieur" ? "M" : "Mme");
    this.email = formattedAttributes.email;
    this.birthDate = formattedAttributes.birthDate;
    this.birthName = formattedAttributes.birthName;
    this.city = formattedAttributes.city;
    this.postalCode = formattedAttributes.postalCode;
    this.fullAddress = formattedAttributes.fullAddress || this.formatAddress();
    this.affiliationNumber = formattedAttributes.affiliationNumber;
    this.phoneNumber = formatPhoneNumber(formattedAttributes.phoneNumber);
    this.customId = formattedAttributes.customId;
    // CONJOINT/CONCUBIN/PACSE => conjoint
    const formattedRole = formattedAttributes.role?.split("/")?.shift()?.toLowerCase();
    this.role = ROLES[formattedRole] || formattedRole;
    this.shortRole = (this.role === "demandeur" ? "DEM" : "CJT");
    this.departmentNumber = departmentNumber;
    this.departmentConfiguration = departmentConfiguration;
  }

  get uid() {
    return this.generateUid();
  }

  get createdAt() {
    return this._createdAt;
  }

  get lastEmailInvitationSentAt() {
    return this._lastEmailInvitationSentAt;
  }

  get lastSmsInvitationSentAt() {
    return this._lastSmsInvitationSentAt;
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

  set lastEmailInvitationSentAt(lastEmailInvitationSentAt) {
    this._lastEmailInvitationSentAt = lastEmailInvitationSentAt;
  }

  set lastSmsInvitationSentAt(lastSmsInvitationSentAt) {
    this._lastSmsInvitationSentAt = lastSmsInvitationSentAt;
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
    this.lastSmsInvitationSentAt =
      retrieveLastInvitationDate(upToDateApplicant.invitations, "sms");
    this.lastEmailInvitationSentAt =
      retrieveLastInvitationDate(upToDateApplicant.invitations, "email");
  }

  formatAddress() {
    return (
      (this.address ?? "") +
      (this.postalCode ? ` - ${this.postalCode}` : "") +
      (this.city ? ` - ${this.city}` : "")
    );
  }

  shouldDisplay(attribute) {
    return this.departmentConfiguration.column_names[attribute];
  }

  shouldBeInvitedBySms() {
    return this.departmentConfiguration.invitation_format === ("sms" || "sms_and_email");
  }

  shouldBeInvitedByEmail() {
    return this.departmentConfiguration.invitation_format === ("email" || "sms_and_email");
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
