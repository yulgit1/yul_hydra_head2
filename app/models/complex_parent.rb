require "active-fedora"
class ComplexParent < ActiveFedora::Base
  #ERJ, below for reference 
  #include ::ActiveFedora::DatastreamCollections
  #include ::ActiveFedora::Relationships
  has_metadata :name => 'descMetadata', :type => Hydra::Datastream::SimpleMods
  has_metadata :name => 'accessMetadata', :type => Hydra::Datastream::AccessConditions
  has_metadata :name => 'rightsMetadata', :type => Hydra::Datastream::Rights
  #ERJ, has datastream (from::ActiveFedora::DatastreamCollections)  not used, params not propagated to fedora 
  #has_datastream :name => 'tif', :type=>ActiveFedora::Datastream,:mimeType=>"image/tiff", :controlGroup=>'M',:checksumType=>'MD5'
  #has_datastream :name => 'jpg', :type=>ActiveFedora::Datastream,:mimeType=>"image/jpg", :controlGroup=>'M',:checksumType=>'MD5'
  #has_datastream :name => 'jp2', :type=>ActiveFedora::Datastream,:mimeType=>"image/jp2", :controlGroup=>'M',:checksumType=>'MD5'
  
  #ERJ, below for reference  
  #has_metadata :name => 'propertyMetadata', :type => ActiveFedora::MetadataDatastream do |m|
  #  m.field 'title', :string
  #end	
end