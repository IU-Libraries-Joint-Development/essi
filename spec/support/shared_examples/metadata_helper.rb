RSpec.shared_examples "MARC Relators" do
  it "includes extended MARC Relator metadata" do
    # Comes from including ESSI::ExtendedMetadata
    # Test a small subset of the properties available.
    expect(subject).to respond_to(:arranger)
    expect(subject).to respond_to(:author)
    expect(subject).to respond_to(:dubious_author)
  end
end

RSpec.shared_examples "Image Properties" do
  it "includes extended Image metadata" do
    # Comes from including ESSI::ImageMetadata
    # Test a small subset of the properties available.
    expect(subject).to respond_to(:digital_specifications)
  end
end

RSpec.shared_examples "BibRecord Properties" do
  it "includes extended Bibliographic Record metadata" do
    # Comes from including ESSI::BibRecordMetadata
    # Test a small subset of the properties available.
    expect(subject).to respond_to(:bib_editor)
    expect(subject).to respond_to(:bib_article)
  end
end

RSpec.shared_examples "PagedResource Properties" do
  it "includes extended PagedResource metadata" do
    # Comes from including ESSI::PagedResourceMetadata
    # Test a small subset of the properties available.
    expect(subject).to respond_to(:viewing_hint)
    expect(subject).to respond_to(:viewing_direction)
    expect(subject).to respond_to(:ocr_state)
  end
end

RSpec.shared_examples "Scientific Properties" do
  it "includes extended Darwin Core metadata" do
    # Comes from including ESSI::ScientificMetadata
    # Test a small subset of the properties available.
    expect(subject).to respond_to(:kingdom)
    expect(subject).to respond_to(:phylum)
  end
end
