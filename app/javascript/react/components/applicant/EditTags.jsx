import React, { useEffect, useCallback } from "react";
import { observer } from "mobx-react-lite";

import MultiSelect from "./MultiSelect";

import Applicant from "../../models/Applicant";

const EditTags = observer(({
  applicant: applicantProp,
  organisation,
  department,
  tags
}) => {
  const [isEditingTags, setIsEditingTags] = React.useState(false)
  const [applicant, setApplicant] = React.useState(null)

  useEffect(() => {
    setApplicant(new Applicant({
      id: applicantProp.id,
      createdAt: applicantProp.created_at,
      tags: applicantProp.tags.map(tag => tag.value),
    }, department, organisation, tags))
  }, [])

  return (
    <>
      {isEditingTags && (
        <MultiSelect
          applicant={applicant}
          cell="tags"
          values={tags.map(tag => tag.value)}
          setIsEditingMultiselect={() => window.location.reload()}
        />
      )}
      <button type="button" className="btn btn-primary mb-3" onClick={useCallback(() => setIsEditingTags(true))}>
        <i className="fas fa-pen" /> Modifier les catégories d'usagers
      </button>
    </>
  )
})

export default (props) => (
  <EditTags {...props} />
)