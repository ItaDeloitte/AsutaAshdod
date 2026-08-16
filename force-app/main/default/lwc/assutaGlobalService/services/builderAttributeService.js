import { utils } from '../utils';

class BuilderAttributeService {
  buildAttributesFromFields(cmp, fields = [], fromLwc = false) {
    const attributes = fields.reduce((acc, field) => {
      acc[field] = fromLwc ? cmp[field] : utils.attribute(cmp, field);
      return acc;
    }, {});
    return attributes;
  }
}

export const builderAttributeService = new BuilderAttributeService();