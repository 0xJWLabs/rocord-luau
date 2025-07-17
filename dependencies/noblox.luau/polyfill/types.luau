export type Object = { [string]: any }
export type Array<T> = { [number]: T }
export type Function = (...any) -> ...any
export type Table<T, V> = { [T]: V }
export type Tuple<T, V> = Array<T | V>

return {}
