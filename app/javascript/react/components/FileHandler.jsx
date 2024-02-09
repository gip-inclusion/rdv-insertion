import React, { useState, useRef } from "react";

import PendingMessage from "./PendingMessage";

const DEFAULT_UPLOAD_MESSAGE = "Glissez et déposez le fichier à analyser ou sélectionnez le.";
const DEFAULT_PENDING_MESSAGE = "Calcul des statistiques en cours, merci de patienter";

export default function FileHandler({
  handleFile,
  fileSize,
  loading = () => {},
  accept,
  name,
  multiple = true,
  pendingMessage = DEFAULT_PENDING_MESSAGE,
  uploadMessage = DEFAULT_UPLOAD_MESSAGE,
}) {
  const [isPending, setIsPending] = useState(false);
  const hiddenFileInput = useRef(null);

  const handleFiles = async (filesToHandle) => {
    await Promise.all([...filesToHandle].map(async (file) => handleFile(file)));
    setIsPending(false);
    loading(false);
  };

  const handleUploads = (event) => {
    const filesToHandle = event.target.files;
    setIsPending(true);
    loading(true);
    handleFiles(filesToHandle);
  };

  return (
    <>
      <p className="text-center">
        {isPending && <PendingMessage message={pendingMessage} fileSize={fileSize} />}
        {!isPending && uploadMessage}
      </p>
      <div className="text-center">
        <input
          type="file"
          name={name}
          className="d-none"
          accept={accept}
          onChange={handleUploads}
          multiple={multiple}
          ref={hiddenFileInput}
        />
        <button
          type="button"
          className="btn btn-blue"
          onClick={() => hiddenFileInput.current.click()}
        >
          Choisir un fichier
        </button>
      </div>
    </>
  );
}
