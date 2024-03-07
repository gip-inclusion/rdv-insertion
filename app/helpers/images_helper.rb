module ImagesHelper
  def uploaded_logo_path(image)
    url_for(controller: "uploaded_images", action: "show", id: image.id)
  end
end
