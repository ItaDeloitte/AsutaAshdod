import { EventEmitter } from './classUtils/EventEmitter';
import { ClassSet } from './classUtils/ClassSet';

class ClassUtils {
  EventEmitter = EventEmitter;
  ClassSet = ClassSet;
}

export const classUtils = new ClassUtils();