import formatPhoneNumber from "../../lib/formatPhoneNumber";
import retrieveLastInvitationDate from "../../lib/retrieveLastInvitationDate";

const ROLES = {
  allocataire: "demandeur",
  dem: "demandeur",
  cjt: "conjoint",
};

const TITLES = {
  mr: "monsieur",
  mme: "madame",
};

export default class Applicant {
  constructor(attributes, department, organisation, organisationConfiguration) {
    const formattedAttributes = {};
    Object.keys(attributes).forEach((key) => {
      formattedAttributes[key] = attributes[key]?.toString()?.trim();
    });
    this.address = formattedAttributes.address;
    this.lastName = formattedAttributes.lastName;
    this.firstName = formattedAttributes.firstName;
    this.title = this.formatTitle(formattedAttributes.title);
    this.shortTitle = this.title ? (this.title === "monsieur" ? "M" : "Mme") : null;
    this.email = formattedAttributes.email;
    this.birthDate = formattedAttributes.birthDate;
    this.birthName = formattedAttributes.birthName;
    this.city = formattedAttributes.city;
    this.postalCode = formattedAttributes.postalCode;
    this.fullAddress = formattedAttributes.fullAddress || this.formatAddress();
    this.departmentInternalId = formattedAttributes.departmentInternalId;
    this.rightsOpeningDate = formattedAttributes.rightsOpeningDate;
    this.affiliationNumber = this.formatAffiliationNumber(formattedAttributes.affiliationNumber);
    this.phoneNumber = formatPhoneNumber(formattedAttributes.phoneNumber);
    this.role = this.formatRole(formattedAttributes.role);
    this.shortRole = this.role ? (this.role === "demandeur" ? "DEM" : "CJT") : null;
    this.department = department;
    this.departmentNumber = department.number;
    // when creating/inviting we always consider an applicant in the scope of only one organisation
    this.currentOrganisation = organisation;
    this.organisationConfiguration = organisationConfiguration;
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

  get lastPostalInvitationSentAt() {
    return this._lastPostalInvitationSentAt;
  }

  get id() {
    return this._id;
  }

  get organisations() {
    return this._organisations;
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

  set lastPostalInvitationSentAt(lastPostalInvitationSentAt) {
    this._lastPostalInvitationSentAt = lastPostalInvitationSentAt;
  }

  set organisations(organisations) {
    this._organisations = organisations;
  }

  formatAffiliationNumber(affiliationNumber) {
    if (affiliationNumber && [13, 15].includes(affiliationNumber.length)) {
      // This means it is a NIR, we replace it by a custom ID if present
      if (this.departmentInternalId) {
        return `CUS-${this.departmentInternalId}`;
      }
      return null;
    }
    return affiliationNumber;
  }

  formatTitle(title) {
    title = title?.toLowerCase();
    title = TITLES[title] || title;
    if (!Object.values(TITLES).includes(title)) return null;
    return title;
  }

  formatRole(role) {
    // CONJOINT/CONCUBIN/PACSE => conjoint
    // CONJOINT(E) => conjoint
    role = role?.split("/")?.shift()?.split("(")?.shift()?.toLowerCase();
    role = ROLES[role] || role;
    if (!Object.values(ROLES).includes(role)) return null;
    return role;
  }

  updateWith(upToDateApplicant) {
    this.createdAt = upToDateApplicant.created_at;
    this.invitedAt = upToDateApplicant.invited_at;
    this.id = upToDateApplicant.id;
    this.organisations = upToDateApplicant.organisations;
    // we assign a current organisation when we are in the context of a department
    this.currentOrganisation ||= upToDateApplicant.organisations.find(
      (o) => o.department_number === this.departmentNumber
    );
    // we update the attributes with the attributes in DB if the applicant is already created
    // and cannot be updated from the page
    if (this.belongsToCurrentOrg()) {
      this.firstName = upToDateApplicant.first_name;
      this.lastName = upToDateApplicant.last_name;
      this.email = upToDateApplicant.email;
      this.phoneNumber = formatPhoneNumber(upToDateApplicant.phone_number);
      this.fullAddress = upToDateApplicant.address;
    }
    this.lastSmsInvitationSentAt = retrieveLastInvitationDate(upToDateApplicant.invitations, "sms");
    this.lastEmailInvitationSentAt = retrieveLastInvitationDate(
      upToDateApplicant.invitations,
      "email"
    );
    this.lastPostalInvitationSentAt = retrieveLastInvitationDate(
      upToDateApplicant.invitations,
      "postal"
    );
    this.departmentInternalId = upToDateApplicant.department_internal_id;
  }

  updatePhoneNumber(phoneNumber) {
    this.phoneNumber = formatPhoneNumber(phoneNumber);
  }

  updateEmail(email) {
    this.email = email;
  }

  formatAddress() {
    return (
      (this.address ?? "") +
      (this.postalCode ? ` ${this.postalCode}` : "") +
      (this.city ? ` ${this.city}` : "")
    );
  }

  shouldDisplay(attribute) {
    return (
      this.organisationConfiguration.column_names.required[attribute] ||
      (this.organisationConfiguration.column_names.optional &&
        this.organisationConfiguration.column_names.optional[attribute])
    );
  }

  shouldBeInvitedBySms() {
    return this.organisationConfiguration.invitation_formats.includes("sms");
  }

  shouldBeInvitedByEmail() {
    return this.organisationConfiguration.invitation_formats.includes("email");
  }

  shouldBeInvitedByPostal() {
    return this.organisationConfiguration.invitation_formats.includes("postal");
  }

  belongsToCurrentOrg() {
    return (
      this.currentOrganisation &&
      this.organisations.map((o) => o.id).includes(this.currentOrganisation.id)
    );
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
      ...(this.departmentInternalId && { department_internal_id: this.departmentInternalId }),
      ...(this.rightsOpeningDate && { rights_opening_date: this.rightsOpeningDate }),
    };
  }
}
