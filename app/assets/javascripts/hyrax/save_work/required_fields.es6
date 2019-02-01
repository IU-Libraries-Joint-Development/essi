// Override stock Hyrax version to support mutex (mutually exclusive) fieldsets
// If at least one of mutex_a/mutex_b class fieldsets are present, at least one set must be complete
export class RequiredFields {
  // Monitors the form and runs the callback if any of the required fields change
  constructor(form, callback) {
    this.form = form
    this.callback = callback
    this.reload()
  }

  get areComplete() {
    return this.alwaysRequired.filter((n, elem) => { return this.isValuePresent(elem) } ).length === 0 &&
           ((this.mutexFieldsA.length === 0 && this.mutexFieldsB.length === 0) ||
            (this.mutexFieldsA.length > 0 && this.mutexFieldsA.filter((n, elem) => { return this.isValuePresent(elem) } ).length === 0) ||
            (this.mutexFieldsB.length > 0 && this.mutexFieldsB.filter((n, elem) => { return this.isValuePresent(elem) } ).length === 0))
  }

  isValuePresent(elem) {
    return ($(elem).val() === null) || ($(elem).val().length < 1)
  }

  // Reassign requiredFields because fields may have been added or removed.
  reload() {
    // ":input" matches all input, select or textarea fields.
    this.requiredFields = this.form.find(':input[required]')
    this.mutexFieldsA = this.form.find(':input[required].mutex_a')
    this.mutexFieldsB = this.form.find(':input[required].mutex_b')
    this.alwaysRequired = this.form.find(':input[required]').not('.mutex_a, .mutex_b')
    this.requiredFields.change(this.callback)
  }
}
