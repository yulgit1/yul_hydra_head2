require "active-fedora"
class ComplexParent < ActiveFedora::Base
  include ::ActiveFedora::DatastreamCollections
  include ::ActiveFedora::Relationships
  has_metadata :name => 'descMetadata', :type => Hydra::Datastream::SimpleMods
  has_metadata :name => 'accessMetadata', :type => Hydra::Datastream::AccessConditions
  has_metadata :name => 'rightsMetadata', :type => Hydra::Datastream::Rights
  #has_datastream :name => 'tif', :type=>ActiveFedora::Datastream, :mimeType=>"image/tiff", :controlGroup=>'M'
  #has_datastream :name => 'jpg', :type=>ActiveFedora::Datastream, :mimeType=>"image/jpg", :controlGroup=>'M'
  #has_datastream :name => 'jp2', :type=>ActiveFedora::Datastream, :mimeType=>"image/jp2", :controlGroup=>'M'
  #has_metadata :name => 'descMetadata', :type => Hydra::Datastream::ModsGenericContent
  #has_metadata :name => 'descMetadata', :type => ActiveFedora::Datastream
  #has_metadata :name => 'descMetadata', :type => Hydra::Datastream::ModsYulContent
  #has_metadata :name => 'descMetadata', :type => ActiveFedora::MetadataDatastream do |m|
  #  m.field 'title', :string
  #end	
end