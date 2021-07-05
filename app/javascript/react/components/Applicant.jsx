import React, { useState } from "react";
import Swal from "sweetalert2";
import createApplicant from "../actions/createApplicant";

export default function Applicant({ applicant, dispatchApplicants }) {
  const [isLoading, setIsLoading] = useState(false);

  const handleClick = async () => {
    setIsLoading(true);
    if (applicant.callToAction() === "CREER COMPTE") {
      const result = await createApplicant(applicant);
      if (result.success) {
        applicant.addRdvSolidaritesData(result.augmented_applicant);

        dispatchApplicants({
          type: "update",
          item: {
            seed: applicant.id,
            applicant,
          },
        });
      } else {
        Swal.fire(
          "Impossible de créer l'utilisateur",
          result.errors[0],
          "error"
        );
      }
    }
    setIsLoading(false);
  };

  return (
    <tr key={applicant.id}>
      <td>{applicant.affiliationNumber}</td>
      <td>{applicant.firstName}</td>
      <td>{applicant.lastName}</td>
      <td>{applicant.fullAddress()}</td>
      <td>{applicant.email}</td>
      <td>{applicant.phoneNumber}</td>
      <td>{applicant.birthDate}</td>
      <td>{applicant.role}</td>
      <td className="text-nowrap">{applicant.createdAt ?? " - "}</td>
      <td className="text-nowrap">{applicant.invitedAt ?? " - "}</td>
      <td>
        {!applicant.invitedAt && (
          <button
            type="submit"
            disabled={isLoading}
            className="btn btn-primary"
            onClick={() => handleClick()}
          >
            {isLoading ? applicant.loadingAction() : applicant.callToAction()}
          </button>
        )}
      </td>
    </tr>
  );
}
