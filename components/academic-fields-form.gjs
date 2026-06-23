import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { on } from "@ember/modifier";
import eq from "truth-helpers/helpers/eq";
import ComboBox from "select-kit/components/combo-box";

export default class AcademicFieldsForm extends Component {
  @tracked selectedMainField = this.args.model.main_field || null;
  @tracked selectedSubFields = this.args.model.sub_fields || [];

  get mainFieldOptions() {
    return [
      { id: "engineering", name: "Engineering & Tech" },
      { id: "humanities", name: "Humanities & Arts" }
    ];
  }

  @action
  updateMainField(value) {
    this.selectedMainField = value;
    this.selectedSubFields = []; 
    this.args.model.setProperties({ main_field: value, sub_fields: [] });
  }

  @action
  toggleSubField(event) {
    const value = event.target.value;
    let newSelection = [...this.selectedSubFields];
    
    if (event.target.checked) {
      newSelection.push(value);
    } else {
      newSelection = newSelection.filter(f => f !== value);
    }
    
    this.selectedSubFields = newSelection;
    this.args.model.set('sub_fields', newSelection);
  }

  <template>
    <div class="academic-profile-fields">
      <div class="control-group">
        <label>Primary Discipline</label>
        <ComboBox
          @content={{this.mainFieldOptions}}
          @value={{this.selectedMainField}}
          @onChange={{this.updateMainField}}
        />
      </div>

      {{#if (eq this.selectedMainField "engineering")}}
        <div class="sub-fields-group">
          <label><input type="checkbox" value="computer_science" {{on "change" this.toggleSubField}} /> Computer Science</label>
          <label><input type="checkbox" value="civil_engineering" {{on "change" this.toggleSubField}} /> Civil Engineering</label>
        </div>
      {{/if}}
    </div>
  </template>
}