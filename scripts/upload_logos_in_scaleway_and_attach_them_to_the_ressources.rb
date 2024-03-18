# rails runner scripts/upload_logos_in_scaleway_and_attach_them_to_the_ressources.rb

def available_format(logo_name)
  %w[png jpg].find do |format|
    AssetHelper.asset_exists?("logos/#{logo_name}.#{format}")
  end
end

def upload_logo(resource, logo_name)
  format = available_format(logo_name).presence
  puts "No logo found for #{resource.name}" unless format
  return unless format

  logo_path = Rails.root.join("app/assets/images/logos/#{logo_name}.#{format}")
  file = File.open(logo_path)
  resource.logo.attach(io: file, filename: "#{logo_name}.#{format}", content_type: "image/#{format}")
  file.close
  puts "Logo uploaded for #{resource.name}"
end

Department.find_each do |department|
  puts "Uploading logo for department id: #{department.id} name: #{department.name}"
  upload_logo(department, department.name.parameterize)
end

Organisation.find_each do |organisation|
  puts "Uploading logo for organisation id: #{organisation.id} name: #{organisation.name}"
  logo_name = organisation.logo_filename.presence || organisation.name.parameterize
  upload_logo(organisation, logo_name)
end
