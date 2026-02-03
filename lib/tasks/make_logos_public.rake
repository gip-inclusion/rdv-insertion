desc "Met à jour l'ACL des logos existants et bascule leur service vers scaleway_public"
task make_logos_public: :environment do
  [Department, Organisation].each do |model|
    model.find_each do |record|
      next unless record.logo.attached?

      blob = record.logo.blob
      blob.service.bucket.object(blob.key).acl.put(acl: "public-read")
      blob.update!(service_name: "scaleway_public")
      puts "#{model.name} ##{record.id}: ACL et service mis à jour"
    end
  end
end
