import React from "react";
import { getFrenchFormatDateString } from "../../../lib/datesHelper";

export default function InvitationsDatesRow({
  invitationsDatesByFormat,
  invitationFormats,
  index,
}) {
  console.log(invitationsDatesByFormat);
  console.log(invitationFormats);
  return (
    <tr>
      {invitationFormats.map((format) => (
        <td className="px-4 py-3" key={format + index}>
          {invitationsDatesByFormat[format][index]
            ? getFrenchFormatDateString(invitationsDatesByFormat[format][index])
            : index === 0
            ? "-"
            : ""}
        </td>
      ))}
    </tr>
  );
}
