RSpec.shared_examples "ExtraLockable Behaviors" do
  describe "#lock_manager" do
    it "delegates to LockManagerService" do
      expect(LockManagerService).to receive(:lock_manager)
      curation_concern.lock_manager
    end
  end
  describe "#lock_checker" do
    it "delegates to LockManagerService" do
      expect(LockManagerService).to receive(:lock_checker)
      curation_concern.lock_checker
    end
  end
  describe "#acquire_lock_for(lock_key, &block)" do
    it "acquires lock through lock_manager" do
      expect(LockManagerService.lock_manager).to receive(:lock)
      curation_concern.acquire_lock_for(curation_concern.lock_id)
    end
  end
  describe "#check_lock_for(lock_key, &block)" do
    it "checks lock through lock_checker" do
      expect(LockManagerService.lock_checker).to receive(:lock)
      curation_concern.check_lock_for(curation_concern.lock_id)
    end
  end
  describe "#lock?" do
    it "calls lock_checker's #lock" do
      expect(LockManagerService.lock_checker).to receive(:lock)
      curation_concern.lock?
    end
  end
  describe "#lock_id" do
    context "with a blank lock id attribute" do
      before(:each) { allow(curation_concern).to receive(:id).and_return(nil) }
      it "raises an ArgumentError" do
        expect { curation_concern.lock_id }.to raise_error ArgumentError
      end
    end
    context "with a non-blank lock id attribute" do
      it "returns a String" do
        expect(curation_concern.lock_id).to match /^lock_/
      end
    end
  end
  describe "#lock(key, options)" do
    it "passes call to underlying Redlock client" do
      expect(LockManagerService.lock_manager.client).to receive(:lock)
      curation_concern.lock
    end
  end
  describe "#lock?" do
    context "on a locked resource" do
      it "returns true" do
        curation_concern.lock
        expect(curation_concern.lock?).to eq true
      end
    end
    context "on an unlocked resource" do
      it "returns false" do
        expect(curation_concern.lock?).to eq false
      end
    end
  end
  describe "#unlock(lock_info)" do
    it "calls lock_manager's client's unlock" do
      expect(LockManagerService.lock_manager.client).to receive(:unlock)
      curation_concern.unlock({})
    end
  end
end
