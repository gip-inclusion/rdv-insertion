import React, { useState } from "react";
import Swal from "sweetalert2";
import Tippy from "@tippyjs/react";

import handleApplicantCreation from "../lib/handleApplicantCreation";
import handleApplicantInvitation from "../lib/handleApplicantInvitation";
import handleApplicantUpdate from "../lib/handleApplicantUpdate";
import handleApplicantUnarchive from "../lib/handleApplicantUnarchive";
import retrieveRelevantOrganisation from "../../lib/retrieveRelevantOrganisation";
import { getFrenchFormatDateString } from "../../lib/datesHelper";
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
    applicantUnarchive: false,
  });
  const handleUpdateContactsDataClick = async (attribute = null) => {
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

  const handleUnarchiveApplicantClick = async () => {
    setIsLoading({ ...isLoading, applicantUnarchive: true });

    const result = await handleApplicantUnarchive(applicant);

    if (result.success) {
      Swal.fire("Dossier de l'allocataire rouvert avec succès", "", "info");
    }
    setIsLoading({ ...isLoading, organisationUpdate: false });
  };

  const handleInvitationClick = async (format) => {
    setIsLoading({ ...isLoading, [`${format}Invitation`]: true });
    const invitationParams = [
      applicant.id,
      applicant.department.id,
      applicant.currentOrganisation.id,
      isDepartmentLevel,
      applicant.currentConfiguration.motif_category,
      applicant.currentOrganisation.phone_number,
    ];
    if (format === "sms") {
      await handleApplicantInvitation(...invitationParams, "sms");
      applicant.SmsInvitationSuccessfullySent = true;
    } else if (format === "email") {
      await handleApplicantInvitation(...invitationParams, "email");
      applicant.emailInvitationSuccessfullySent = true;
    } else if (format === "postal") {
      setDownloadInProgress(true);
      const createLetter = await handleApplicantInvitation(...invitationParams, "postal");
      if (createLetter?.success) {
        applicant.postalInvitationSuccessfullySent = true;
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
        applicant.linkedOrganisationSearchTerms,
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

        {/* ------------------------------- Account creation cell ----------------------------- */}

        {applicant.isArchived ? (
          <td>
            <button
              type="submit"
              disabled={isLoading.applicantUnarchive}
              className="btn btn-primary btn-blue"
              onClick={() => handleUnarchiveApplicantClick()}
            >
              Rouvrir le dossier
            </button>
          </td>
        ) : applicant.createdAt ? (
          !applicant.belongsToCurrentOrg() ? (
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
              <td>
                <button
                  type="submit"
                  disabled={isLoading.organisationUpdate}
                  className="btn btn-primary btn-blue"
                  onClick={() => handleAddToOrganisationClick()}
                >
                  {isLoading.organisationUpdate ? "En cours..." : "Ajouter à cette organisation"}
                </button>
              </td>
            </Tippy>
          ) : applicant.currentContextStatus === "not_invited" ? (
            <td>Compte existant mais jamais invité dans ce contexte</td>
          ) : (
            // if applicant belongs to current rdv_context, we give extra infos to the agent
            <Tippy
              content={
                <span>
                  Compte créé le&nbsp;
                  {getFrenchFormatDateString(applicant.createdAt)}
                  {/* In case of pending context, invitations are disabled */}
                  {/* and the following infos are displayed in the invitations cells */}
                  {!applicant.pendingContextStatus() && (
                    <>
                      {applicant.lastInvitationSentAt && (
                        <>
                          <br />
                          Dernière invitation envoyée le&nbsp;
                          {getFrenchFormatDateString(applicant.lastInvitationSentAt)}
                        </>
                      )}
                      {applicant.lastNonWaitingRdvDate && (
                        <>
                          <br />
                          Date du dernier RDV&nbsp;: le&nbsp;
                          {getFrenchFormatDateString(applicant.lastNonWaitingRdvDate)}
                        </>
                      )}
                      <br />
                      <strong>{applicant.currentRdvContext.human_status}</strong>
                    </>
                  )}
                </span>
              }
            >
              <td>
                Existe déjà dans ce contexte&nbsp;
                <i className="fas fa-question-circle" />
              </td>
            </Tippy>
          )
        ) : applicant.isDuplicate ? (
          <td>
            <button type="submit" disabled className="btn btn-primary btn-blue">
              Création impossible
            </button>
          </td>
        ) : (
          <td>
            <button
              type="submit"
              disabled={isLoading.accountCreation}
              className="btn btn-primary btn-blue"
              onClick={() => handleCreationClick("accountCreation")}
            >
              {isLoading.accountCreation ? "Création..." : "Créer compte"}
            </button>
          </td>
        )}

        {/* --------------------------------- Invitations cells ------------------------------- */}

        {/* ----------------------------- Disabled invitations cases -------------------------- */}

        {applicant.isArchived ? (
          <td colSpan={computeColSpanForDisabledInvitations()}>
            Dossier archivé
            {applicant.archiving_reason && <>&nbsp;: {applicant.archiving_reason}</>}
          </td>
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
        ) : applicant.pendingContextStatus() ? (
          <>
            <Tippy
              content={
                <span>
                  {applicant.currentContextStatus === "invitation_pending" ? (
                    <>
                      Dernière invitation envoyée le&nbsp;
                      {getFrenchFormatDateString(applicant.lastInvitationSentAt)}
                    </>
                  ) : (
                    <>
                      Date du RDV&nbsp;: le&nbsp;
                      {getFrenchFormatDateString(applicant.lastWaitingRdvDate)}
                    </>
                  )}
                </span>
              }
            >
              <td colSpan={computeColSpanForDisabledInvitations()}>
                {applicant.currentRdvContext.human_status}&nbsp;
                <i className="fas fa-question-circle" />
              </td>
            </Tippy>
          </>
        ) : (
          /* ----------------------------- Enabled invitations cases --------------------------- */

          <>
            {/* --------------------------------- SMS Invitations ------------------------------- */}

            {applicant.shouldBeInvitedBySms() && (
              <>
                <td>
                  {applicant.SmsInvitationSuccessfullySent ? (
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

            {/* ------------------------------- Email Invitations ----------------------------- */}

            {applicant.shouldBeInvitedByEmail() && (
              <>
                <td>
                  {applicant.emailInvitationSuccessfullySent ? (
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

            {/* ------------------------------ Postal Invitations ----------------------------- */}

            {applicant.shouldBeInvitedByPostal() && (
              <>
                <td>
                  {applicant.postalInvitationSuccessfullySent ? (
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

      {/* ------------------------------ Contact infos extra line ----------------------------- */}

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
                        onClick={() => handleUpdateContactsDataClick(attributeName)}
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
                onClick={() => handleUpdateContactsDataClick("allAttributes")}
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
