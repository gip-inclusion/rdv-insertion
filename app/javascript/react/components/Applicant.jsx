import React, { useState } from "react";
import Swal from "sweetalert2";
import Tippy from "@tippyjs/react";

import handleApplicantCreation from "../lib/handleApplicantCreation";
import handleApplicantInvitation from "../lib/handleApplicantInvitation";
import handleApplicantUpdate from "../lib/handleApplicantUpdate";
import retrieveRelevantOrganisation from "../../lib/retrieveRelevantOrganisation";
import getInvitationLetter from "../actions/getInvitationLetter";
import { todaysDateString } from "../../lib/datesHelper";
import camelToSnakeCase from "../../lib/stringHelper";

export default function Applicant({
  applicant,
  isDepartmentLevel,
  downloadInProgress,
  setDownloadInProgress,
}) {
  const [isLoading, setIsLoading] = useState({
    accountCreation: false,
    smsInvitation: false,
    emailInvitation: false,
    postalInvitation: false,
    organisationUpdate: false,
    emailUpdate: false,
    phoneNumberUpdate: false,
    rightsOpeningDateUpdate: false,
    allAttributesUpdate: false,
  });

  const handleUpdateWithContactsDataFileClick = async (attribute = null) => {
    setIsLoading({ ...isLoading, [`${attribute}Update`]: true });

    const attributes = {};
    if (attribute === "allAttributes") {
      attributes.email = applicant.emailNew;
      attributes.phone_number = applicant.phoneNumberNew;
      attributes.rights_opening_date = applicant.rightsOpeningDateNew;
    } else {
      attributes[`${camelToSnakeCase(attribute)}`] = applicant[`${attribute}New`];
    }

    const result = await handleApplicantUpdate(applicant, attributes);

    if (result.success) {
      if (attribute === "allAttributes") {
        applicant.markAttributeAsUpdated("email");
        applicant.markAttributeAsUpdated("phoneNumber");
        applicant.markAttributeAsUpdated("rightsOpeningDate");
      } else {
        applicant.markAttributeAsUpdated(`${attribute}`);
      }
    }

    setIsLoading({ ...isLoading, [`${attribute}Update`]: false });
  };

  const handleAddToOrganisationClick = async () => {
    setIsLoading({ ...isLoading, organisationUpdate: true });

    const result = await handleApplicantUpdate(applicant, applicant.toJson());

    if (result.success && result.applicant.organisations.length > 1) {
      Swal.fire(
        "Allocataire ajouté",
        "Cet allocataire existait déjà dans une autre organisation du département. Il a été mis à jour et ajouté à votre organisation",
        "info"
      );
    }
    setIsLoading({ ...isLoading, organisationUpdate: false });
  };

  const handleInvitationClick = async (format) => {
    setIsLoading({ ...isLoading, [`${format}Invitation`]: true });
    const invitationParams = [
      applicant,
      applicant.department.id,
      applicant.currentOrganisation,
      isDepartmentLevel,
      applicant.currentConfiguration.context,
      applicant.currentConfiguration.number_of_days_to_accept_invitation,
    ];
    if (format === "sms") {
      const invitation = await handleApplicantInvitation(...invitationParams, "sms");
      applicant.lastSmsInvitationSentAt = invitation.sent_at;
    } else if (format === "email") {
      const invitation = await handleApplicantInvitation(...invitationParams, "email");
      applicant.lastEmailInvitationSentAt = invitation.sent_at;
    } else if (format === "postal") {
      setDownloadInProgress(true);
      const invitationLetter = await getInvitationLetter(...invitationParams, "postal");
      if (invitationLetter?.success) {
        applicant.lastPostalInvitationSentAt = todaysDateString();
      }
      setDownloadInProgress(false);
    }
    setIsLoading({ ...isLoading, [`${format}Invitation`]: false });
  };

  const handleCreationClick = async () => {
    setIsLoading({ ...isLoading, accountCreation: true });

    if (!applicant.currentOrganisation) {
      applicant.currentOrganisation = await retrieveRelevantOrganisation(
        applicant.departmentNumber,
        applicant.fullAddress
      );
      // If there is still no organisation it means the assignation was cancelled by agent
      if (!applicant.currentOrganisation) {
        setIsLoading({ ...isLoading, accountCreation: false });
        return;
      }
    }
    await handleApplicantCreation(applicant, applicant.currentOrganisation.id);

    setIsLoading({ ...isLoading, accountCreation: false });
  };

  const computeColSpanForContactsUpdate = () =>
    applicant.displayedAttributes().length - applicant.attributesFromContactsDataFile().length;

  const computeColSpanForDisabledInvitations = () => {
    let colSpan = 0;
    if (applicant.shouldBeInvitedBySms()) colSpan += 1;
    if (applicant.shouldBeInvitedByEmail()) colSpan += 1;
    if (applicant.shouldBeInvitedByPostal()) colSpan += 1;
    return colSpan;
  };

  return (
    <>
      <tr className={applicant.isDuplicate || applicant.isArchived ? "table-danger" : ""}>
        <td>{applicant.affiliationNumber}</td>
        <td>{applicant.shortTitle}</td>
        <td>{applicant.firstName}</td>
        <td>{applicant.lastName}</td>
        <td>{applicant.shortRole}</td>
        {applicant.shouldDisplay("department_internal_id") && (
          <td>{applicant.departmentInternalId ?? " - "}</td>
        )}
        {applicant.shouldDisplay("birth_date") && <td>{applicant.birthDate ?? " - "}</td>}
        {applicant.shouldDisplay("email") && (
          <td className={applicant.emailUpdated ? "table-success" : ""}>
            {applicant.email ?? " - "}
          </td>
        )}
        {applicant.shouldDisplay("phone_number") && (
          <td className={applicant.phoneNumberUpdated ? "table-success" : ""}>
            {applicant.phoneNumber ?? " - "}
          </td>
        )}
        {applicant.shouldDisplay("rights_opening_date") && (
          <td className={applicant.rightsOpeningDateUpdated ? "table-success" : ""}>
            {applicant.rightsOpeningDate ?? " - "}
          </td>
        )}
        <td>
          {applicant.isArchived ? (
            <button type="submit" disabled className="btn btn-primary btn-blue">
              Dossier archivé
            </button>
          ) : applicant.createdAt ? (
            applicant.belongsToCurrentOrg() ? (
              <i className="fas fa-check" />
            ) : (
              <Tippy
                content={
                  <span>
                    Cet allocataire est déjà présent dans RDV-Insertion dans une autre organisation
                    que l&apos;organisation actuelle.
                    <br />
                    Appuyez sur ce bouton pour ajouter l&apos;allocataire à cette organisation et
                    mettre à jours ses informations.
                  </span>
                }
              >
                <button
                  type="submit"
                  disabled={isLoading.organisationUpdate}
                  className="btn btn-primary btn-blue"
                  onClick={() => handleAddToOrganisationClick()}
                >
                  {isLoading.organisationUpdate ? "En cours..." : "Ajouter à cette organisation"}
                </button>
              </Tippy>
            )
          ) : applicant.isDuplicate ? (
            <button type="submit" disabled className="btn btn-primary btn-blue">
              Création impossible
            </button>
          ) : (
            <button
              type="submit"
              disabled={isLoading.accountCreation}
              className="btn btn-primary btn-blue"
              onClick={() => handleCreationClick("accountCreation")}
            >
              {isLoading.accountCreation ? "Création..." : "Créer compte"}
            </button>
          )}
        </td>
        {applicant.isArchived ? (
          <td colSpan={computeColSpanForDisabledInvitations()} />
        ) : applicant.isDuplicate ? (
          <Tippy
            content={
              <span>
                <strong>Cet allocataire est un doublon.</strong> Les doublons sont identifiés de 2
                façons&nbsp;:
                <br />
                1) Son numéro d&apos;ID éditeur est identique à un autre allocataire présent dans ce
                fichier.
                <br />
                2) Son numéro d&apos;allocataire <strong>et</strong> son rôle sont identiques à ceux
                d&apos;un autre allocataire présent dans ce fichier.
                <br />
                <br />
                Si cet allocataire a besoin d&apos;être créé, merci de modifier votre fichier et de
                le charger à nouveau.
              </span>
            }
          >
            <td colSpan={computeColSpanForDisabledInvitations()}>
              <small className="d-inline-block mx-2">
                <i className="fas fa-exclamation-triangle" />
              </small>
            </td>
          </Tippy>
        ) : (
          <>
            {applicant.shouldBeInvitedBySms() && (
              <>
                <td>
                  {applicant.lastSmsInvitationSentAt ? (
                    <i className="fas fa-check" />
                  ) : (
                    <button
                      type="submit"
                      disabled={
                        isLoading.smsInvitation ||
                        !applicant.createdAt ||
                        !applicant.phoneNumber ||
                        !applicant.belongsToCurrentOrg()
                      }
                      className="btn btn-primary btn-blue"
                      onClick={() => handleInvitationClick("sms")}
                    >
                      {isLoading.smsInvitation ? "Invitation..." : "Inviter par SMS"}
                    </button>
                  )}
                </td>
              </>
            )}
            {applicant.shouldBeInvitedByEmail() && (
              <>
                <td>
                  {applicant.lastEmailInvitationSentAt ? (
                    <i className="fas fa-check" />
                  ) : (
                    <button
                      type="submit"
                      disabled={
                        isLoading.emailInvitation ||
                        !applicant.createdAt ||
                        !applicant.email ||
                        !applicant.belongsToCurrentOrg()
                      }
                      className="btn btn-primary btn-blue"
                      onClick={() => handleInvitationClick("email")}
                    >
                      {isLoading.emailInvitation ? "Invitation..." : "Inviter par mail"}
                    </button>
                  )}
                </td>
              </>
            )}
            {applicant.shouldBeInvitedByPostal() && (
              <>
                <td>
                  {applicant.lastPostalInvitationSentAt ? (
                    <i className="fas fa-check" />
                  ) : (
                    <button
                      type="submit"
                      disabled={
                        isLoading.postalInvitation ||
                        downloadInProgress ||
                        !applicant.createdAt ||
                        !applicant.fullAddress ||
                        !applicant.belongsToCurrentOrg()
                      }
                      className="btn btn-primary btn-blue"
                      onClick={() => handleInvitationClick("postal")}
                    >
                      {isLoading.postalInvitation ? "Création en cours..." : "Générer courrier"}
                    </button>
                  )}
                </td>
              </>
            )}
          </>
        )}
      </tr>
      {(applicant.phoneNumberNew || applicant.emailNew || applicant.rightsOpeningDateNew) && (
        <tr className="table-success">
          <td colSpan={computeColSpanForContactsUpdate()} className="text-align-right">
            <i className="fas fa-level-up-alt" />
            Nouvelles données trouvées pour {applicant.firstName} {applicant.lastName}
          </td>
          {["email", "phoneNumber", "rightsOpeningDate"].map(
            (attributeName) =>
              applicant.shouldDisplay(camelToSnakeCase(attributeName)) && (
                <td
                  className="update-box"
                  key={`${attributeName}${new Date().toISOString().slice(0, 19)}`}
                >
                  {applicant[`${attributeName}New`] && (
                    <>
                      {applicant[`${attributeName}New`]}
                      <br />
                      <button
                        type="submit"
                        className="btn btn-primary btn-blue btn-sm mt-2"
                        onClick={() => handleUpdateWithContactsDataFileClick(attributeName)}
                      >
                        {isLoading[`${attributeName}Update`] || isLoading.allAttributesUpdate
                          ? "En cours..."
                          : "Mettre à jour"}
                      </button>
                    </>
                  )}
                </td>
              )
          )}
          <td>
            {[applicant.emailNew, applicant.phoneNumberNew, applicant.rightsOpeningDateNew].filter(
              (e) => e != null
            ).length > 1 && (
              <button
                type="submit"
                className="btn btn-primary btn-blue"
                onClick={() => handleUpdateWithContactsDataFileClick("allAttributes")}
              >
                {isLoading.emailUpdate ||
                isLoading.phoneNumberUpdate ||
                isLoading.rightsOpeningDateUpdate ||
                isLoading.allAttributesUpdate
                  ? "En cours..."
                  : "Tout mettre à jour"}
              </button>
            )}
          </td>
          <td colSpan={computeColSpanForDisabledInvitations()} />
        </tr>
      )}
    </>
  );
}
