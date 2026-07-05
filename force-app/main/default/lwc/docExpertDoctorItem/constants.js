import { labels } from './labels';

export const doctorDetailTypes = {
  clinics: 'clinics',
  arrangements: 'arrangements',
  procedures: 'procedures',
  sites: 'sites'
};

export const detailsTypeToTitle = {
  clinics: labels.Clinics,
  arrangements: labels.Arrangements,
  procedures: labels.Procedures,
  sites: labels.Sites
};

export const detailLinks = [
  { label: labels.Clinics, type: doctorDetailTypes.clinics },
  // { label: labels.Arrangements, type: doctorDetailTypes.arrangements },
  { label: labels.Procedures, type: doctorDetailTypes.procedures },
  { label: labels.Sites, type: doctorDetailTypes.sites }
];