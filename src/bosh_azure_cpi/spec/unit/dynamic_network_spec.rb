require "spec_helper"

describe Bosh::AzureCloud::DynamicNetwork do
  let(:azure_properties) { mock_azure_properties }

  context "when all properties are specified" do
    let(:dns) { "fake-dns" }
    let(:vnet_name) { "fake-vnet-name" }
    let(:subnet_name) { "fake-subnet-name" }
    let(:rg_name) { "fake-resource-group-name" }
    let(:nsg_name) { "fake-nsg-name" }
    let(:asg_names) { ["fake-asg-name-1", "fake-asg-name-2"] }
    let(:network_spec) {
      {
        "default" => ["dns", "gateway"],
        "dns" => dns,
        "cloud_properties" => {
          "virtual_network_name"        => vnet_name,
          "subnet_name"                 => subnet_name,
          "resource_group_name"         => rg_name,
          "security_group"              => nsg_name,
          "application_security_groups" => asg_names
        }
      }
    }

    it "should return properties with right values" do
      network = Bosh::AzureCloud::DynamicNetwork.new(azure_properties, "default", network_spec)

      expect(network.resource_group_name).to eq(rg_name)
      expect(network.virtual_network_name).to eq(vnet_name)
      expect(network.subnet_name).to eq(subnet_name)
      expect(network.security_group).to eq(nsg_name)
      expect(network.application_security_groups).to eq(asg_names)
      expect(network.dns).to eq(dns)
      expect(network.has_default_dns?).to be true
      expect(network.has_default_gateway?).to be true
    end
  end

  context "when missing cloud_properties" do
    let(:network_spec) {
      {
        "fake-key" => "fake-value"
      }
    }

    it "should raise an error" do
        expect {
          Bosh::AzureCloud::DynamicNetwork.new(azure_properties, "default", network_spec)
        }.to raise_error(/cloud_properties required for dynamic network/)
    end
  end

  context "when virtual_network_name is invalid" do
    context "when missing virtual_network_name" do
      let(:network_spec) {
        {
          "cloud_properties"=>{
            "subnet_name"=>"bar"
          }
        }
      }

      it "should raise an error" do
          expect {
            Bosh::AzureCloud::DynamicNetwork.new(azure_properties, "default", network_spec)
          }.to raise_error(/virtual_network_name required for dynamic network/)
      end
    end

    context "when virtual_network_name is nil" do
      let(:network_spec) {
        {
          "cloud_properties"=>{
            "virtual_network_name"=>nil,
            "subnet_name"=>"bar"
          }
        }
      }

      it "should raise an error" do
          expect {
            Bosh::AzureCloud::DynamicNetwork.new(azure_properties, "default", network_spec)
          }.to raise_error(/virtual_network_name required for dynamic network/)
      end
    end
  end

  context "when subnet_name is invalid" do
    context "when missing subnet_name" do
      let(:network_spec) {
        {
          "cloud_properties"=>{
            "virtual_network_name"=>"foo"
          }
        }
      }

      it "should raise an error" do
          expect {
            Bosh::AzureCloud::DynamicNetwork.new(azure_properties, "default", network_spec)
          }.to raise_error(/subnet_name required for dynamic network/)
      end
    end

    context "when subnet_name is nil" do
      let(:network_spec) {
        {
          "cloud_properties"=>{
            "virtual_network_name"=>"foo",
            "subnet_name"=>nil
          }
        }
      }

      it "should raise an error" do
          expect {
            Bosh::AzureCloud::DynamicNetwork.new(azure_properties, "default", network_spec)
          }.to raise_error(/subnet_name required for dynamic network/)
      end
    end
  end

  context "when security_group is not specified" do
    let(:network_spec) {
      {
        "cloud_properties"=>{
          "virtual_network_name"=>"foo",
          "subnet_name"=>"bar"
        }
      }
    }

    it "should return nil for security_group" do
      network = Bosh::AzureCloud::DynamicNetwork.new(azure_properties, "default", network_spec)
      expect(network.security_group).to be_nil
    end
  end

  context "when application_security_groups are not specified" do
    let(:network_spec) {
      {
        "cloud_properties"=>{
          "virtual_network_name"=>"foo",
          "subnet_name"=>"bar"
        }
      }
    }

    it "should return an empty array for application_security_groups" do
      network = Bosh::AzureCloud::DynamicNetwork.new(azure_properties, "default", network_spec)
      expect(network.application_security_groups).to eq([])
    end
  end

  context "when resource_group_name is not specified" do
    let(:network_spec) {
      {
        "cloud_properties"=>{
          "virtual_network_name"=>"foo",
          "subnet_name"=>"bar"
        }
      }
    }

    it "should return resource_group_name from global azure properties" do
      network = Bosh::AzureCloud::DynamicNetwork.new(azure_properties, "default", network_spec)
      expect(network.resource_group_name).to eq(azure_properties["resource_group_name"])
    end
  end

  context "when default dns and gateway are not specified" do
    let(:network_spec) {
      {
        "cloud_properties"=>{
          "virtual_network_name"=>"foo",
          "subnet_name"=>"bar"
        }
      }
    }

    it "should return nil for :dns, return false for :has_default_dns?, return false for :has_default_gateway?" do
      network = Bosh::AzureCloud::DynamicNetwork.new(azure_properties, "default", network_spec)
      expect(network.dns).to be_nil
      expect(network.has_default_dns?).to be false
      expect(network.has_default_dns?).to be false
    end
  end
end
