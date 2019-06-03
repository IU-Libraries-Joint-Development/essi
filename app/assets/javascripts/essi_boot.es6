import ModalViewer from "modal_viewer"
import BulkLabeler from "bulk_labeler/bulk_label"
import StructureManager from "structure_manager"
import Flash from "flash"
import EssiFileManager from "file_manager/essi"
export default class Initializer {
  constructor() {
    this.modal_viewer = new ModalViewer
    this.structure_manager = new StructureManager
    this.bulk_labeler = new BulkLabeler
    this.initialize_essi_file_manager()
    this.flash = new Flash
  }

    initialize_essi_file_manager() {
        this.essi_file_manager = new EssiFileManager
    }
}
