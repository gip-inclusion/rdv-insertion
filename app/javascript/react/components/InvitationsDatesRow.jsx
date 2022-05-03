import React from "react";
import { getFrenchFormatDateString } from "../../lib/datesHelper";

export default function InvitationsDatesRow({
  invitationsDatesByFormat,
  invitationFormats,
  index,
}) {
  const showInvitation = (format) => invitationFormats.includes(format);

  return (
    <tr>
      {showInvitation("sms") && (
        <td className="px-4 py-3">
          {invitationsDatesByFormat.sms[index]
            ? getFrenchFormatDateString(invitationsDatesByFormat.sms[index])
            : index === 0
            ? "-"
            : ""}
        </td>
      )}
      {showInvitation("email") && (
        <td className="px-4 py-3">
          {invitationsDatesByFormat.email[index]
            ? getFrenchFormatDateString(invitationsDatesByFormat.email[index])
            : index === 0
            ? "-"
            : ""}
        </td>
      )}
      {showInvitation("postal") && (
        <td className="px-4 py-3">
          {invitationsDatesByFormat.postal[index]
            ? getFrenchFormatDateString(invitationsDatesByFormat.postal[index])
            : index === 0
            ? "-"
            : ""}
        </td>
      )}
    </tr>
  );
}
