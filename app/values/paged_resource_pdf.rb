class PagedResourcePDF
  attr_reader :paged_resource, :quality
  def initialize(paged_resource, quality: "gray")
    @paged_resource = paged_resource
    @quality = quality
  end

  def pages
    manifest_builder.canvases.length + 1 # Extra page is coverpage
  end

  def render(path, force: false)
    if File.exist?(path) && !force
      File.open(path)
    else
      Renderer.new(self, path).render
    end
  end

  def manifest_builder
    @manifest_builder ||= PolymorphicManifestBuilder.new(paged_resource)
  end
end