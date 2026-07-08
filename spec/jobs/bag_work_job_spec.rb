require 'rails_helper'

describe BagWorkJob do
  let(:identifier) { 'finished_work' } 
  let(:bags_path) { Rails.root.join('tmp', 'test_bags' ) }
  let(:dropbox_path) { Rails.root.join('spec', 'fixtures', 'bagit', identifier) }

  before(:each) {
    # Ensure clean bags_path
    FileUtils.remove_dir(bags_path, force: true)
    FileUtils.mkdir(bags_path)
  }

  after(:suite) do
    FileUtils.remove_dir(bags_path)
  end
    
  context "with uploaded files left in a dropbox" do
    before(:each) do
      # Create a new bag by calling perform on described_class
      bag_info = { "Bag-Software-Agent" => "rspec",
               "Contact-Name" => "Rspec",
               "Custom-data" => "Some Value" }
      described_class.perform_now(identifier, dropbox_path, bags_path, bag_info)
    end

    it "created a bag based on an identifier" do
      # Open newly created bag for validation
      bag = BagIt::Bag.new File.join(bags_path, identifier)
      expect(bag.valid?).to be_truthy
    end

    it "created a data directory with copies of files" do
      # Open newly created bag for file validation
      bag = BagIt::Bag.new File.join(bags_path, identifier)
      expect(bag.bag_files.count).to equal(2)
    end

    it "created a bag with correct info" do
      # Open newly created bag for info validation
      bag = BagIt::Bag.new File.join(bags_path, identifier)
      expect(bag.bag_info.keys).to include("Custom-data")
    end
  end

  context "removes and overwrites existing bag" do
    before(:each) do
      bag_info = { "Custom-data" => "Initial bag" }
      described_class.perform_now(identifier, dropbox_path, bags_path, bag_info)
    end

    it "creates the initial bag" do
      bag = BagIt::Bag.new File.join(bags_path, identifier)
      expect(bag.valid?).to be_truthy
      expect(bag.bag_info.values).to include("Initial bag")
    end

    it "overwrites bag with different files" do
      tmp_dropbox = File.join(bags_path, 'tmp_dropbox')
      FileUtils.mkdir(tmp_dropbox)
      FileUtils.cp_r(Dir.glob(File.join(dropbox_path, '*.png')), tmp_dropbox)
      FileUtils.cp(File.join(dropbox_path,'finished_work_01.png'),
                   File.join(tmp_dropbox, 'finished_work_04.png'))
      FileUtils.cp(File.join(dropbox_path,'finished_work_01.png'),
                   File.join(tmp_dropbox, 'finished_work_05.png'))
      described_class.perform_now(identifier, tmp_dropbox, bags_path)
      bag = BagIt::Bag.new File.join(bags_path, identifier)
      expect(bag.bag_info.values).to include("Initial bag")
      expect(bag.bag_files.count).to equal(4)
      expect(bag.bag_files.to_s).to include("finished_work_04")
      expect(bag.bag_files.to_s).to include("finished_work_01")
    end
  end
end
