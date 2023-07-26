import { makeAutoObservable } from "mobx"
import formatPhoneNumber from "../../lib/formatPhoneNumber";
import retrieveLastInvitationDate from "../../lib/retrieveLastInvitationDate";
import handleApplicantCreation from "../lib/handleApplicantCreation";
import retrieveRelevantOrganisation from "../../lib/retrieveRelevantOrganisation";
import handleApplicantInvitation from "../lib/handleApplicantInvitation";
import { getFrenchFormatDateString } from "../../lib/datesHelper";

const ROLES = {
  allocataire: "demandeur",
  dem: "demandeur",
  cjt: "conjoint",
};

const TITLES = {
  m: "monsieur",
  mr: "monsieur",
  mme: "madame",
};

export default class Applicant {
  constructor(
    attributes,
    department,
    organisation,
    currentConfiguration,
    columnNames,
    currentAgent
  ) {
    const formattedAttributes = {};
    Object.keys(attributes).forEach((key) => {
      formattedAttributes[key] = attributes[key]?.toString()?.trim();
    });
    this._id = formattedAttributes.id;
    this._createdAt = formattedAttributes.createdAt;
    this._organisations = formattedAttributes.organisations || [];
    this.phoneNumberNew = null;
    this.lastName = formattedAttributes.lastName;
    this.firstName = formattedAttributes.firstName;
    this.title = this.formatTitle(formattedAttributes.title);
    this.shortTitle = this.title ? (this.title === "monsieur" ? "M" : "Mme") : null;
    this.email = formattedAttributes.email;
    this.birthDate = formattedAttributes.birthDate;
    this.birthName = formattedAttributes.birthName;
    this.addressFirstField = formattedAttributes.addressFirstField;
    this.addressSecondField = formattedAttributes.addressSecondField;
    this.addressThirdField = formattedAttributes.addressThirdField;
    this.addressFourthField = formattedAttributes.addressFourthField;
    this.addressFifthField = formattedAttributes.addressFifthField;
    this.fullAddress = this.formatFullAddress();
    this.departmentInternalId = formattedAttributes.departmentInternalId;
    this.nir = formattedAttributes.nir;
    this.poleEmploiId = formattedAttributes.poleEmploiId;
    this.rightsOpeningDate = formattedAttributes.rightsOpeningDate;
    this.affiliationNumber = formattedAttributes.affiliationNumber;
    this.phoneNumber = formatPhoneNumber(formattedAttributes.phoneNumber);
    this.role = this.formatRole(formattedAttributes.role);
    this.shortRole = this.role ? (this.role === "demandeur" ? "DEM" : "CJT") : null;
    this.linkedOrganisationSearchTerms = formattedAttributes.linkedOrganisationSearchTerms;
    this.referentEmail = formattedAttributes.referentEmail || currentAgent?.email;

    this.department = department;
    this.departmentNumber = department.number;
    // when creating/inviting we always consider an applicant in the scope of only one organisation
    this.currentOrganisation = organisation;
    this.currentConfiguration = currentConfiguration;
    this.columnNames = columnNames;
    this.selected = false;
    this.archives = [];

    this.resetErrors();

    this.triggers = {
      creation: false,
      unarchive: false,
      smsInvitation: false,
      emailInvitation: false,
      postalInvitation: false,
      referentAssignation: false,
      emailUpdate: false,
      phoneNumberUpdate: false,
      rightsOpeningDateUpdate: false,
      allAttributesUpdate: false,
      carnetCreation: false,
    };

    makeAutoObservable(this);
  }

  get uid() {
    return this.generateUid();
  }

  get createdAt() {
    return this._createdAt;
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

  async inviteBy(format, isDepartmentLevel, options = { raiseError: true }) {
    if (!this.createdAt) {
      const success = await this.createAccount(options);
      if (!success) return false;
    }

    if (format === "sms" && !this.phoneNumber) return false;
    if (format === "email" && !this.email) return false;
    if (format === "postal" && !this.fullAddress) return false;

    this.triggers[`${format}Invitation`] = true;
    const invitationParams = [
      this.id,
      this.department.id,
      this.currentOrganisation.id,
      isDepartmentLevel,
      this.currentConfiguration.motif_category_id,
      this.currentOrganisation.phone_number,
    ];
    const result = await handleApplicantInvitation(...invitationParams, format);
    if (result.success) {
      // dates are set as json to match the API format
      this.updateLastInvitationDate(format, new Date().toJSON());
    }
    this.triggers[`${format}Invitation`] = false;
    return true
  } 

  async createAccount(options = { raiseError: true }) {
    this.triggers.creation = true;
    this.resetErrors();

    if (!this.currentOrganisation) {
      this.currentOrganisation = await retrieveRelevantOrganisation(
        this.departmentNumber,
        this.linkedOrganisationSearchTerms,
        this.fullAddress,
        { raiseError: options.raiseError }
      );

      // If there is still no organisation it means the assignation was cancelled by agent
      if (!this.currentOrganisation) {
        this.triggers.creation = false;
        if (!options.raiseError) this.errors.push("Vous devez associer une organisation à cet utilisateur")
        return false;
      }

    }
    const { errors, success } = await handleApplicantCreation(this, this.currentOrganisation.id, {
      raiseError: options.raiseError,
    });

    if (!success) {
      this.errors = errors;
    }

    this.triggers.creation = false;

    return success
  }

  resetErrors() {
    this.errors = []
  }

  get isValid() {
    return !this.errors || this.errors.length === 0
  }

  updateWith(upToDateApplicant) {
    this.resetErrors();
    this.createdAt = upToDateApplicant.created_at;
    this.invitedAt = upToDateApplicant.invited_at;
    this.id = upToDateApplicant.id;
    this.archives = upToDateApplicant.archives;
    this.organisations = upToDateApplicant.organisations;
    this.carnet_de_bord_carnet_id = upToDateApplicant.carnet_de_bord_carnet_id;
    // we assign a current organisation when we are in the context of a department
    this.currentOrganisation ||= upToDateApplicant.organisations.find(
      (o) =>
        o.department_number === this.departmentNumber &&
        // if we are in a specific context we choose an org that handles that category
        (!this.currentConfiguration ||
          o.motif_categories
            .map((motifCategory) => motifCategory.id)
            .includes(this.currentConfiguration.motif_category_id))
    );
    this.referents = upToDateApplicant.referents;
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
      this.nir = upToDateApplicant.nir;
      this.affiliationNumber = upToDateApplicant.affiliation_number;
      this.role = upToDateApplicant.role;
      this.departmentInternalId = upToDateApplicant.department_internal_id;
    }
    if (this.currentConfiguration) {
      this.currentRdvContext = upToDateApplicant.rdv_contexts.find(
        (rc) => rc.motif_category_id === this.currentConfiguration.motif_category_id
      );
      this.currentContextStatus = this.currentRdvContext && this.currentRdvContext.status;
      this.participations = this.currentRdvContext?.participations || [];
      this.lastSmsInvitationSentAt = retrieveLastInvitationDate(
        upToDateApplicant.invitations,
        "sms",
        this.currentConfiguration.motif_category_id
      );
      this.lastEmailInvitationSentAt = retrieveLastInvitationDate(
        upToDateApplicant.invitations,
        "email",
        this.currentConfiguration.motif_category_id
      );
      this.lastPostalInvitationSentAt = retrieveLastInvitationDate(
        upToDateApplicant.invitations,
        "postal",
        this.currentConfiguration.motif_category_id
      );
    }
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
      (this.addressFirstField ? `${this.addressFirstField} ` : "") +
      (this.addressSecondField ? `${this.addressSecondField} ` : "") +
      (this.addressThirdField ? `${this.addressThirdField} ` : "") +
      (this.addressFourthField ? `${this.addressFourthField} ` : "") +
      (this.addressFifthField ?? "")
    ).trim();
  }

  displayedAttributes() {
    const attributes = [
      this.affiliationNumber,
      this.shortTitle,
      this.firstName,
      this.lastName,
      this.shortRole,
    ];
    if (this.shouldDisplay("department_internal_id_column"))
      attributes.push(this.departmentInternalId);
    if (this.shouldDisplay("email_column")) attributes.push(this.email);
    if (this.shouldDisplay("phone_number_column")) attributes.push(this.phoneNumber);
    if (this.shouldDisplay("rights_opening_date_column")) attributes.push(this.rightsOpeningDate);
    return attributes;
  }

  attributesFromContactsDataFile() {
    const attributes = [];
    if (this.shouldDisplay("email_column")) attributes.push(this.email);
    if (this.shouldDisplay("phone_number_column")) attributes.push(this.phoneNumber);
    if (this.shouldDisplay("rights_opening_date_column")) attributes.push(this.rightsOpeningDate);
    return attributes;
  }

  shouldDisplay(attribute) {
    return Object.keys(this.columnNames).includes(attribute);
  }

  canBeInvitedBy(format) {
    if (!this.currentConfiguration) return false;
    return this.currentConfiguration.invitation_formats.includes(format);
  }

  belongsToCurrentOrg() {
    return (
      this.currentOrganisation &&
      this.organisations.map((o) => o.id).includes(this.currentOrganisation.id)
    );
  }

  linkedToCurrentCategory() {
    return this.organisations.some((organisation) =>
      organisation.motif_categories
        .map((motifCategory) => motifCategory.id)
        .includes(this.currentConfiguration.motif_category_id)
    );
  }

  hasParticipations() {
    return this.participations && this.participations.length > 0;
  }

  sortedParticipationsByCreationDate() {
    return this.participations.sort((a, b) => new Date(a.created_at) - new Date(b.created_at));
  }

  lastParticipationCreatedAt() {
    return this.hasParticipations()
      ? this.sortedParticipationsByCreationDate()[
          this.sortedParticipationsByCreationDate().length - 1
        ].created_at
      : null;
  }

  requiredAttributeToInviteBy(format) {
    switch (format) {
      case "sms":
        return this.phoneNumber;
      case "email":
        return this.email;
      case "postal":
        return this.fullAddress;
      default:
        return null;
    }
  }

  lastInvitationDate(format) {
    switch (format) {
      case "sms":
        return this.lastSmsInvitationSentAt;
      case "email":
        return this.lastEmailInvitationSentAt;
      case "postal":
        return this.lastPostalInvitationSentAt;
      default:
        return null;
    }
  }

  updateLastInvitationDate(format, date) {
    switch (format) {
      case "sms":
        this.lastSmsInvitationSentAt = date;
        return null;
      case "email":
        this.lastEmailInvitationSentAt = date;
        return null;
      case "postal":
        this.lastPostalInvitationSentAt = date;
        return null;
      default:
        return null;
    }
  }

  markAsAlreadyInvitedBy(format) {
    // We cannot re-invite if the applicant is invited in this format and if the applicant has no rdvs yet,
    // or if he has been reinvted after the last rdv
    const lastInvitationDate = this.lastInvitationDate(format);
    return (
      lastInvitationDate &&
      (!this.hasParticipations() ||
        new Date(lastInvitationDate) > new Date(this.lastParticipationCreatedAt()))
    );
  }

  referentAlreadyAssigned() {
    return (
      this.referentEmail &&
      this.referents &&
      this.referents.some((referent) => referent.email === this.referentEmail)
    );
  }

  archiveInCurrentDepartment() {
    return this.archives.find((archive) => archive.department_id === this.department.id);
  }

  isArchivedInCurrentDepartment() {
    return this.archives && this.archiveInCurrentDepartment();
  }

  generateUid() {
    // Base64 encoded "departmentNumber - affiliationNumber - role"

    const attributeIsMissing = [this.affiliationNumber, this.role].some((attribute) => !attribute);
    if (attributeIsMissing) {
      return null;
    }
    return btoa(`${this.affiliationNumber} - ${this.role}`);
  }

  asJson() {
    return {
      title: this.title,
      last_name: this.lastName,
      first_name: this.firstName,
      ...(this.fullAddress && { address: this.fullAddress }),
      ...(this.role && { role: this.role }),
      ...(this.affiliationNumber && { affiliation_number: this.affiliationNumber }),
      ...(this.phoneNumber && { phone_number: this.phoneNumber }),
      ...(this.email && this.email.includes("@") && { email: this.email }),
      ...(this.birthDate && { birth_date: this.birthDate }),
      ...(this.birthName && { birth_name: this.birthName }),
      ...(this.departmentInternalId && { department_internal_id: this.departmentInternalId }),
      ...(this.rightsOpeningDate && { rights_opening_date: this.rightsOpeningDate }),
      ...(this.nir && { nir: this.nir }),
      ...(this.poleEmploiId && { pole_emploi_id: this.poleEmploiId }),
      ...(this.currentConfiguration && {
        rdv_contexts_attributes: [
          { motif_category_id: this.currentConfiguration.motif_category_id },
        ],
      }),
    };
  }
}
