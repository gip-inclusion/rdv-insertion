import formatPhoneNumber from "../../lib/formatPhoneNumber";
import retrieveLastInvitationDate from "../../lib/retrieveLastInvitationDate";
import { getFrenchFormatDateString } from "../../lib/datesHelper";

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
  constructor(attributes, department, organisation, currentConfiguration) {
    const formattedAttributes = {};
    Object.keys(attributes).forEach((key) => {
      formattedAttributes[key] = attributes[key]?.toString()?.trim();
    });
    this.lastName = formattedAttributes.lastName;
    this.firstName = formattedAttributes.firstName;
    this.title = this.formatTitle(formattedAttributes.title);
    this.shortTitle = this.title ? (this.title === "monsieur" ? "M" : "Mme") : null;
    this.email = formattedAttributes.email;
    this.birthDate = formattedAttributes.birthDate;
    this.birthName = formattedAttributes.birthName;
    // address is street name and street number
    this.address = formattedAttributes.address;
    // sometimes street number is separated from address
    this.streetNumber = formattedAttributes.streetNumber;
    this.streetType = formattedAttributes.streetType;
    this.city = formattedAttributes.city;
    this.postalCode = formattedAttributes.postalCode;
    this.fullAddress = formattedAttributes.fullAddress || this.formatFullAddress();
    this.departmentInternalId = formattedAttributes.departmentInternalId;
    this.rightsOpeningDate = formattedAttributes.rightsOpeningDate;
    this.affiliationNumber = formattedAttributes.affiliationNumber;
    this.phoneNumber = formatPhoneNumber(formattedAttributes.phoneNumber);
    this.role = this.formatRole(formattedAttributes.role);
    this.shortRole = this.role ? (this.role === "demandeur" ? "DEM" : "CJT") : null;
    this.department = department;
    this.departmentNumber = department.number;
    // when creating/inviting we always consider an applicant in the scope of only one organisation
    this.currentOrganisation = organisation;
    this.currentConfiguration = currentConfiguration;
    this.isDuplicate = false;
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
    this.isArchived = upToDateApplicant.is_archived;
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
      if (upToDateApplicant.rights_opening_date) {
        this.rightsOpeningDate = getFrenchFormatDateString(upToDateApplicant.rights_opening_date);
      }
    }
    this.lastSmsInvitationSentAt = retrieveLastInvitationDate(
      upToDateApplicant.invitations,
      "sms",
      this.currentConfiguration.motif_category
    );
    this.lastEmailInvitationSentAt = retrieveLastInvitationDate(
      upToDateApplicant.invitations,
      "email",
      this.currentConfiguration.motif_category
    );
    this.lastPostalInvitationSentAt = retrieveLastInvitationDate(
      upToDateApplicant.invitations,
      "postal",
      this.currentConfiguration.motif_category
    );
    this.departmentInternalId = upToDateApplicant.department_internal_id;
  }

  updatePhoneNumber(phoneNumber) {
    this.phoneNumber = formatPhoneNumber(phoneNumber);
  }

  markAttributeAsUpdated(attribute) {
    this[`${attribute}New`] = null;
    this[`${attribute}Updated`] = true;
  }

  formatFullAddress() {
    return (
      (this.streetNumber ? `${this.streetNumber} ` : "") +
      (this.streetType ? `${this.streetType} ` : "") +
      (this.address ?? "") +
      (this.postalCode ? ` ${this.postalCode}` : "") +
      (this.city ? ` ${this.city}` : "")
    );
  }

  displayedAttributes() {
    const attributes = [
      this.affiliationNumber,
      this.shortTitle,
      this.firstName,
      this.lastName,
      this.shortRole,
    ];
    if (this.shouldDisplay("department_internal_id")) attributes.push(this.departmentInternalId);
    if (this.shouldDisplay("birth_date")) attributes.push(this.birthDate);
    if (this.shouldDisplay("email")) attributes.push(this.email);
    if (this.shouldDisplay("phone_number")) attributes.push(this.phoneNumber);
    if (this.shouldDisplay("rights_opening_date")) attributes.push(this.rightsOpeningDate);
    return attributes;
  }

  attributesFromContactsDataFile() {
    const attributes = [];
    if (this.shouldDisplay("email")) attributes.push(this.email);
    if (this.shouldDisplay("phone_number")) attributes.push(this.phoneNumber);
    if (this.shouldDisplay("rights_opening_date")) attributes.push(this.rightsOpeningDate);
    return attributes;
  }

  shouldDisplay(attribute) {
    return (
      this.currentConfiguration.column_names.required[attribute] ||
      (this.currentConfiguration.column_names.optional &&
        this.currentConfiguration.column_names.optional[attribute])
    );
  }

  shouldBeInvitedBySms() {
    return this.currentConfiguration.invitation_formats.includes("sms");
  }

  shouldBeInvitedByEmail() {
    return this.currentConfiguration.invitation_formats.includes("email");
  }

  shouldBeInvitedByPostal() {
    return this.currentConfiguration.invitation_formats.includes("postal");
  }

  belongsToCurrentOrg() {
    return (
      this.currentOrganisation &&
      this.organisations.map((o) => o.id).includes(this.currentOrganisation.id)
    );
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
