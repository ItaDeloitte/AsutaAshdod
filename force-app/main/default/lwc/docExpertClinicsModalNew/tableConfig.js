import { labels } from './labels';

export const rowActions = {
  schedule: 'schedule'
};

export const tableColumns = [
  {
    label: labels.Name,
    fieldName: 'recordUrl',
    type: 'url',
    wrapText: true,
    typeAttributes: {
      label: { fieldName: 'name' },
      tooltip: { fieldName: 'name' },
      target: '_blank'
    }
  },
  {
    label: labels.Address,
    fieldName: 'address',
    type: 'text',
    wrapText: true
  },
  {
    label: labels.Phone,
    fieldName: 'phone',
    type: 'phone',
    wrapText: true
  },
  {
    label: labels.WorkingHours,
    fieldName: 'workingHours',
    type: 'text',
    wrapText: true
  },
  {
    label: labels.Calendar,
    fieldName: 'calendar',
    type: 'text',
    wrapText: true
  },
  {
    label: labels.InsuranceFactor,
    fieldName: 'insuranceFactor',
    type: 'text',
    wrapText: true
  },
  {
    label: labels.SiteUrl,
    fieldName: 'siteUrl',
    type: 'url',
    wrapText: true,
    typeAttributes: {
      label: { fieldName: 'siteName' },
      tooltip: { fieldName: 'siteName' },
      target: '_blank'
    }
  },
  {
    label: '',
    type: 'button',
    typeAttributes: { label: labels.Action, name: rowActions.schedule }
  }
];