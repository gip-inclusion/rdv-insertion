import React, { useEffect } from "react";
import { observer } from "mobx-react-lite";

import MultiSelect from "./MultiSelect";

import Applicant from "../../models/Applicant";
import OrganisationTags from "../../models/OrganisationTags";

const EditTags = observer(({
  tags,
  applicant: applicantProp,
  organisation,
  department
}) => {
  const [isEditingTags, setIsEditingTags] = React.useState(false)

  useEffect(() => {
    OrganisationTags.setTags(tags)
  }, [])

  return (
    <>
      {isEditingTags && (
        <MultiSelect
          applicant={new Applicant({
            id: applicantProp.id,
            createdAt: applicantProp.created_at,
            tags: applicantProp.tags.map(tag => tag.value)
          }, department, organisation)}
          cell="tags"
          values={tags.map(tag => tag.value)}
          setIsEditingMultiselect={() => window.location.reload()}
        />
      )}
      <button type="button" className="btn btn-primary mb-3" onClick={() => setIsEditingTags(true)}>
        <i className="fas fa-pen" /> Modifier les catégories d'usagers
      </button>
    </>
  )
})

export default (props) => (
  <EditTags {...props} />
)