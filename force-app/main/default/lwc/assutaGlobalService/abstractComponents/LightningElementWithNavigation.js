//@ts-check
import { LightningElement, wire } from 'lwc';
// @ts-ignore
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';

export class LightningElementWithNavigation extends NavigationMixin(
  LightningElement
) {
  @wire(CurrentPageReference) pageRef;

  /**
   * @returns {LightningElement}
   */
  get elementRef() {
    return /**@type {any}*/ (this);
  }
}