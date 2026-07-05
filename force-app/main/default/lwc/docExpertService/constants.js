import DOC_EXPERT_DASHBOARD_MODAL_RESOURCE from '@salesforce/resourceUrl/docExpertDashboardModal';
import APPOINTMENTS_RESOURCES from '@salesforce/resourceUrl/appointments';

export const DASHBOARD_STYLES_URL = `${DOC_EXPERT_DASHBOARD_MODAL_RESOURCE}/styles.css`;

export { DOC_EXPERT_DASHBOARD_MODAL_RESOURCE, APPOINTMENTS_RESOURCES };

const APPOINTMENT_ASSETS_PATH = `${APPOINTMENTS_RESOURCES}/assets`;
export const spriteSvg = `${APPOINTMENT_ASSETS_PATH}/sprite.svg`;

export const doctorImages = {
  male: `${APPOINTMENT_ASSETS_PATH}/doctor-male.svg`,
  female: `${APPOINTMENT_ASSETS_PATH}/doctor-female.svg`,
  expertLogo: `${APPOINTMENT_ASSETS_PATH}/expert-doc-logo.png`,
  checkCircle: `${spriteSvg}#icon-check-circle`,
  close: `${spriteSvg}#icon-close`
};

export const doctorActions = {
  recommend: 'recommend',
  select: 'select',
  arrangementChange: 'arrangementChange'
};