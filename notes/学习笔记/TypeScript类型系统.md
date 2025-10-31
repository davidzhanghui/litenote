# TypeScript类型系统深入学习笔记

## 1. TypeScript基础类型系统

### 1.1 基础类型

#### 1.1.1 原始类型
TypeScript提供了JavaScript的所有原始类型，并添加了额外的类型安全检查。

```typescript
// 基础原始类型
let isDone: boolean = false;
let decimal: number = 6;
let color: string = "blue";
let fullName: string = `Bob Smith`;
let age: number = 37;
let sentence: string = `Hello, my name is ${fullName}. I'll be ${age + 1} years old next month.`;

// 数组类型
let list1: number[] = [1, 2, 3];
let list2: Array<number> = [1, 2, 3];

// 元组类型 - 固定长度和类型的数组
let x: [string, number];
x = ["hello", 10]; // 正确
// x = [10, "hello"]; // 错误

// 枚举类型
enum Color {
  Red,
  Green,
  Blue
}
let c: Color = Color.Green;

enum Status {
  Pending = "pending",
  Fulfilled = "fulfilled",
  Rejected = "rejected"
}

// any类型 - 绕过类型检查
let notSure: any = 4;
notSure = "maybe a string instead";
notSure = false;

// unknown类型 - 更安全的any类型
let value: unknown = "hello world";
if (typeof value === "string") {
  console.log(value.toUpperCase()); // 类型守卫后可以使用
}

// void类型 - 无返回值
function warnUser(): void {
  console.log("This is a warning message");
}

// null和undefined
let u: undefined = undefined;
let n: null = null;

// never类型 - 永不返回的函数
function error(message: string): never {
  throw new Error(message);
}

function infiniteLoop(): never {
  while (true) {}
}

// object类型 - 非原始类型
let obj: object = { prop: 0 };

// 更具体的对象类型
interface Person {
  name: string;
  age: number;
}

let person: Person = {
  name: "Alice",
  age: 30
};
```

#### 1.1.2 类型推断
TypeScript能够根据上下文自动推断类型，减少冗余的类型注解。

```typescript
// 基础类型推断
let x = 3; // 推断为 number
let y = "hello"; // 推断为 string
let z = [1, 2, 3]; // 推断为 number[]

// 函数返回类型推断
function add(a: number, b: number) {
  return a + b; // 推断返回类型为 number
}

// 上下文类型推断
window.onmousedown = function(mouseEvent) {
  console.log(mouseEvent.button); // mouseEvent被推断为 MouseEvent
};

// 最佳通用类型推断
let zoo = [new Rhino(), new Elephant(), new Snake()];
// 推断为 (Rhino | Elephant | Snake)[]

// 类型断言
let someValue: any = "this is a string";
let strLength: number = (someValue as string).length;
// 或者
let strLength2: number = (<string>someValue).length;

// 非空断言
function processValue(value: string | null) {
  const processed = value!.trim(); // 告诉TypeScript value不为null
  return processed;
}
```

### 1.2 接口和类型别名

#### 1.2.1 接口定义
接口是定义对象形状的主要方式，支持继承、扩展和实现。

```typescript
// 基础接口
interface User {
  name: string;
  age: number;
  readonly id: number; // 只读属性
}

// 可选属性
interface Config {
  width?: number;
  color?: string;
  [propName: string]: any; // 索引签名
}

// 函数类型接口
interface SearchFunc {
  (source: string, subString: string): boolean;
}

let mySearch: SearchFunc = function(source: string, subString: string) {
  return source.search(subString) > -1;
};

// 可索引类型接口
interface StringArray {
  [index: number]: string;
}

let myArray: StringArray = ["Bob", "Fred"];
let myStr: string = myArray[0];

// 类类型接口
interface ClockConstructor {
  new (hour: number, minute: number): ClockInterface;
}

interface ClockInterface {
  tick(): void;
}

class DigitalClock implements ClockInterface {
  constructor(h: number, m: number) {}
  tick() {
    console.log("beep beep");
  }
}

// 接口继承
interface Shape {
  color: string;
}

interface Square extends Shape {
  sideLength: number;
}

let square: Square = {
  color: "blue",
  sideLength: 10
};

// 多重继承
interface Shape {
  color: string;
}

interface PenStroke {
  penWidth: number;
}

interface Square extends Shape, PenStroke {
  sideLength: number;
}

// 混合类型接口
interface Counter {
  (start: number): string;
  interval: number;
  reset(): void;
}

function getCounter(): Counter {
  let counter = (function(start: number) { return start.toString(); }) as Counter;
  counter.interval = 123;
  counter.reset = function() {};
  return counter;
}
```

#### 1.2.2 类型别名
类型别名提供了一种为类型命名的方式，可以用于原始类型、联合类型、元组等。

```typescript
// 基础类型别名
type Name = string;
type NameResolver = () => string;
type NameOrResolver = Name | NameResolver;

function getName(n: NameOrResolver): Name {
  if (typeof n === "string") {
    return n;
  } else {
    return n();
  }
}

// 对象类型别名
type Person = {
  name: string;
  age: number;
};

// 泛型类型别名
type Container<T> = { value: T };

let numberContainer: Container<number> = { value: 123 };
let stringContainer: Container<string> = { value: "hello" };

// 条件类型别名
type TypeName<T> = 
  T extends string ? "string" :
  T extends number ? "number" :
  T extends boolean ? "boolean" :
  T extends undefined ? "undefined" :
  T extends Function ? "function" :
  "object";

type T0 = TypeName<string>; // "string"
type T1 = TypeName<"hello">; // "string"
type T2 = TypeName<() => void>; // "function"

// 映射类型别名
type Readonly<T> = {
  readonly [P in keyof T]: T[P];
};

type Partial<T> = {
  [P in keyof T]?: T[P];
};

interface User {
  name: string;
  age: number;
}

type ReadonlyUser = Readonly<User>;
type PartialUser = Partial<User>;

// 工具类型别名
type Required<T> = {
  [P in keyof T]-?: T[P];
};

type Pick<T, K extends keyof T> = {
  [P in K]: T[P];
};

type Omit<T, K extends keyof T> = Pick<T, Exclude<keyof T, K>>;

type UserWithoutAge = Omit<User, "age">;
```

## 2. 高级类型特性

### 2.1 泛型编程

#### 2.1.1 泛型基础
泛型提供了创建可重用、类型安全的组件的能力。

```typescript
// 泛型函数
function identity<T>(arg: T): T {
  return arg;
}

let output1 = identity<string>("myString");
let output2 = identity<number>(100);

// 类型推断
let output3 = identity("myString"); // 推断为 string

// 泛型接口
interface GenericIdentityFn<T> {
  (arg: T): T;
}

let myIdentity: GenericIdentityFn<number> = identity;

// 泛型类
class GenericNumber<T> {
  zeroValue: T;
  add: (x: T, y: T) => T;
}

let myGenericNumber = new GenericNumber<number>();
myGenericNumber.zeroValue = 0;
myGenericNumber.add = function(x, y) { return x + y; };

// 泛型约束
interface Lengthwise {
  length: number;
}

function loggingIdentity<T extends Lengthwise>(arg: T): T {
  console.log(arg.length); // 现在知道arg有length属性
  return arg;
}

loggingIdentity({ length: 10, value: 3 }); // 正确
// loggingIdentity(3); // 错误，数字没有length属性

// 在泛型约束中使用类型参数
function getProperty<T, K extends keyof T>(obj: T, key: K) {
  return obj[key];
}

let x = { a: 1, b: 2, c: 3, d: 4 };
getProperty(x, "a"); // 正确
// getProperty(x, "m"); // 错误: 参数'm'不在'a', 'b', 'c', 'd'中

// 泛型工厂函数
function create<T>(c: { new(): T }): T {
  return new c();
}

class BeeKeeper {
  hasMask: boolean = true;
}

class ZooKeeper {
  nametag: string = "Mikle";
}

class Animal {
  numLegs: number = 4;
}

class Bee extends Animal {
  keeper: BeeKeeper = new BeeKeeper();
}

class Lion extends Animal {
  keeper: ZooKeeper = new ZooKeeper();
}

function createInstance<A extends Animal>(c: new() => A): A {
  return new c();
}

createInstance(Lion).keeper.nametag; // 类型推断正确
```

#### 2.1.2 高级泛型模式
```typescript
// 条件泛型类型
type ApiResponse<T> = 
  T extends string ? { message: T } :
  T extends number ? { value: T } :
  T extends boolean ? { flag: T } :
  { data: T };

type StringResponse = ApiResponse<string>; // { message: string }
type NumberResponse = ApiResponse<number>; // { value: number }
type ObjectResponse = ApiResponse<{ id: number }>; // { data: { id: number } }

// 映射泛型类型
type Optional<T, K extends keyof T> = Omit<T, K> & Partial<Pick<T, K>>;

interface UserConfig {
  name: string;
  age: number;
  email: string;
}

type UserConfigOptionalEmail = Optional<UserConfig, "email">;

// 递归泛型类型
type DeepReadonly<T> = {
  readonly [P in keyof T]: T[P] extends object ? DeepReadonly<T[P]> : T[P];
};

interface NestedObject {
  a: number;
  b: {
    c: string;
    d: {
      e: boolean;
    };
  };
}

type DeepReadonlyNested = DeepReadonly<NestedObject>;

// 泛型工具类型
type NonNullable<T> = T extends null | undefined ? never : T;

type ExtractType<T, U> = T extends U ? T : never;
type ExcludeType<T, U> = T extends U ? never : T;

type StringsOnly = ExtractType<string | number | boolean, string>;
type NonStrings = ExcludeType<string | number | boolean, string>;

// 泛型默认类型
interface GenericWithDefault<T = string> {
  value: T;
}

let stringWithDefault: GenericWithDefault = { value: "hello" };
let numberWithDefault: GenericWithDefault<number> = { value: 123 };

// 泛型条件推断
type Unpack<T> = T extends (infer U)[] ? U :
                 T extends (...args: any[]) => infer U ? U :
                 T extends Promise<infer U> ? U :
                 T;

type ArrayType = Unpack<string[]>; // string
type FunctionReturn = Unpack<() => number>; // number
type PromiseValue = Unpack<Promise<boolean>>; // boolean
```

### 2.2 联合类型和交叉类型

#### 2.2.1 联合类型
联合类型允许一个值可以是几种类型之一。

```typescript
// 基础联合类型
type StringOrNumber = string | number;

function printId(id: StringOrNumber) {
  if (typeof id === "string") {
    console.log(id.toUpperCase());
  } else {
    console.log(id.toFixed(2));
  }
}

// 字面量联合类型
type Theme = "light" | "dark";
type Status = "pending" | "fulfilled" | "rejected";

function setTheme(theme: Theme) {
  // theme只能是 "light" 或 "dark"
}

// 可辨识联合类型
interface Square {
  kind: "square";
  size: number;
}

interface Rectangle {
  kind: "rectangle";
  width: number;
  height: number;
}

interface Circle {
  kind: "circle";
  radius: number;
}

type Shape = Square | Rectangle | Circle;

function area(s: Shape): number {
  switch (s.kind) {
    case "square":
      return s.size * s.size;
    case "rectangle":
      return s.width * s.height;
    case "circle":
      return Math.PI * s.radius ** 2;
    default:
      // 确保所有情况都被处理
      const _exhaustiveCheck: never = s;
      return _exhaustiveCheck;
  }
}

// 联合类型的类型守卫
function isString(value: unknown): value is string {
  return typeof value === "string";
}

function processValue(value: string | number) {
  if (isString(value)) {
    // 这里value的类型被收窄为string
    console.log(value.toUpperCase());
  } else {
    // 这里value的类型是number
    console.log(value.toFixed(2));
  }
}

// in操作符类型守卫
interface Car {
  drive(): void;
}

interface Boat {
  sail(): void;
}

function useVehicle(vehicle: Car | Boat) {
  if ("drive" in vehicle) {
    vehicle.drive(); // vehicle被推断为Car
  } else {
    vehicle.sail(); // vehicle被推断为Boat
  }
}

// instanceof类型守卫
class Bird {
  fly() {
    console.log("Bird flying");
  }
}

class Fish {
  swim() {
    console.log("Fish swimming");
  }
}

function move(animal: Bird | Fish) {
  if (animal instanceof Bird) {
    animal.fly();
  } else {
    animal.swim();
  }
}
```

#### 2.2.2 交叉类型
交叉类型将多个类型合并为一个类型。

```typescript
// 基础交叉类型
interface Person {
  name: string;
}

interface Employee {
  id: number;
  department: string;
}

type EmployeePerson = Person & Employee;

let employee: EmployeePerson = {
  name: "John",
  id: 123,
  department: "Engineering"
};

// 函数的交叉类型
interface Function1 {
  (a: number): string;
}

interface Function2 {
  (b: string): number;
}

// 这个交叉类型实际上无法实现，因为参数类型冲突
// type ImpossibleFunction = Function1 & Function2;

// 实际的函数交叉类型
type FunctionWithProps = (() => void) & {
  prop: string;
};

const funcWithProps: FunctionWithProps = () => {
  console.log("function with props");
};
funcWithProps.prop = "hello";

// 对象的交叉类型
type WithRequired<T, K extends keyof T> = T & Required<Pick<T, K>>;

interface User {
  name?: string;
  age?: number;
  email?: string;
}

type UserWithRequiredName = WithRequired<User, "name">;
// 现在name是必需的，其他属性仍然是可选的

// 泛型交叉类型
type Merge<T, U> = {
  [K in keyof T | keyof U]: K extends keyof U ? U[K] : K extends keyof T ? T[K] : never;
};

type Merged = Merge<Person, Employee>;

// 条件交叉类型
type ConditionalMerge<T, U> = T extends object ? U extends object ? Merge<T, U> : T : U;

// 使用交叉类型实现混入
type Constructor<T = {}> = new (...args: any[]) => T;

function Timestamped<TBase extends Constructor>(Base: TBase) {
  return class extends Base {
    timestamp = Date.now();
  };
}

class User {
  constructor(public name: string) {}
}

const TimestampedUser = Timestamped(User);
const user = new TimestampedUser("Alice");
console.log(user.name); // Alice
console.log(user.timestamp); // 时间戳
```

## 3. 类型操作和工具类型

### 3.1 映射类型

#### 3.1.1 基础映射类型
映射类型通过遍历现有类型的属性来创建新类型。

```typescript
// 基础映射类型
type Readonly<T> = {
  readonly [P in keyof T]: T[P];
};

type Partial<T> = {
  [P in keyof T]?: T[P];
};

interface User {
  name: string;
  age: number;
  email: string;
}

type ReadonlyUser = Readonly<User>;
type PartialUser = Partial<User>;

// 自定义映射类型
type Stringify<T> = {
  [K in keyof T]: string;
};

type StringifiedUser = Stringify<User>;
// { name: string; age: string; email: string; }

// 映射类型修饰符
type Mutable<T> = {
  -readonly [P in keyof T]: T[P];
};

type Required<T> = {
  [P in keyof T]-?: T[P];
};

type MutableReadonlyUser = Mutable<ReadonlyUser>;
type AllRequiredUser = Required<PartialUser>;

// 条件映射类型
type Nullable<T> = {
  [P in keyof T]: T[P] | null;
};

type OptionalNullable<T> = {
  [P in keyof T]?: T[P] | null;
};

// 重映射
type Getters<T> = {
  [K in keyof T as `get${Capitalize<string & K>}`]: () => T[K];
};

interface Person {
  name: string;
  age: number;
  location: string;
}

type PersonGetters = Getters<Person>;
// {
//   getName: () => string;
//   getAge: () => number;
//   getLocation: () => string;
// }

// 过滤属性
type StringKeys<T> = {
  [K in keyof T as T[K] extends string ? K : never]: T[K];
};

interface MixedTypes {
  name: string;
  age: number;
  email: string;
  id: number;
}

type OnlyStrings = StringKeys<MixedTypes>;
// { name: string; email: string; }

// 递归映射类型
type DeepPartial<T> = {
  [P in keyof T]?: T[P] extends object ? DeepPartial<T[P]> : T[P];
};

interface NestedConfig {
  database: {
    host: string;
    port: number;
    credentials: {
      username: string;
      password: string;
    };
  };
  server: {
    port: number;
    host: string;
  };
}

type PartialConfig = DeepPartial<NestedConfig>;
// 所有嵌套属性都变为可选
```

#### 3.1.2 高级映射模式
```typescript
// 映射类型与条件类型结合
type NonNullableFields<T> = {
  [K in keyof T]: null extends T[K] ? never : K;
}[keyof T];

type RequiredFields<T> = Pick<T, NonNullableFields<T>>;

interface Example {
  name: string;
  age?: number;
  email: string | null;
  phone?: string | null;
}

type RequiredExample = RequiredFields<Example>;
// { name: string; email: string | null; }

// 创建对象类型的工厂函数
type ObjectFromKeys<T extends string, U> = {
  [K in T]: U;
};

type StringKeys = "name" | "age" | "email";
type UserObject = ObjectFromKeys<StringKeys, string>;
// { name: string; age: string; email: string; }

// 动态属性名类型
type EventHandlers<T> = {
  [K in keyof T as T[K] extends (...args: any[]) => any ? K : never]: T[K];
};

interface Events {
  click: (event: MouseEvent) => void;
  hover: (event: MouseEvent) => void;
  focus: (event: FocusEvent) => void;
  data: string; // 不是函数
}

type EventHandlersOnly = EventHandlers<Events>;
// { click: (event: MouseEvent) => void; hover: (event: MouseEvent) => void; focus: (event: FocusEvent) => void; }

// 映射类型与模板字面量类型
type EventNameToHandler<T extends Record<string, any>> = {
  [K in keyof T as `on${Capitalize<string & K>}`]: T[K];
};

type EventHandlers = EventNameToHandler<Events>;
// { onClick: (event: MouseEvent) => void; onHover: (event: MouseEvent) => void; onFocus: (event: FocusEvent) => void; }

// 复杂的映射类型转换
type Flatten<T> = T extends object ? {
  [K in keyof T]: T[K] extends infer U 
    ? U extends object 
      ? Flatten<U> 
      : U 
    : never;
} : T;

// 类型安全的对象键操作
type KeyOf<T> = keyof T;
type ValueOf<T> = T[keyof T];
type Entry<T> = {
  [K in keyof T]: [K, T[K]];
}[keyof T];

type UserEntry = Entry<User>; // ["name" | "age" | "email", string | number]
```

### 3.2 条件类型

#### 3.2.1 基础条件类型
条件类型根据条件选择类型。

```typescript
// 基础条件类型
type IsString<T> = T extends string ? true : false;

type Test1 = IsString<string>; // true
type Test2 = IsString<number>; // false

// 条件类型与泛型结合
type ArrayOrNot<T> = T extends any[] ? T : T[];

type Test3 = ArrayOrNot<string>; // string[]
type Test4 = ArrayOrNot<number[]>; // number[]

// 分布式条件类型
type ToArray<T> = T extends any ? T[] : never;

type StrArrOrNumArr = ToArray<string | number>;
// string[] | number[]

// 条件类型推断
type UnpackArray<T> = T extends (infer U)[] ? U : T;

type UnpackedString = UnpackArray<string[]>; // string
type UnpackedNumber = UnpackArray<number>; // number

// 多层条件类型
type ElementType<T> = 
  T extends string ? "string" :
  T extends number ? "number" :
  T extends boolean ? "boolean" :
  T extends undefined ? "undefined" :
  T extends symbol ? "symbol" :
  T extends Function ? "function" :
  "object";

type StringElement = ElementType<string>; // "string"
type FunctionElement = ElementType<() => void>; // "function"

// 条件类型与映射类型结合
type NonNullable<T> = T extends null | undefined ? never : T;

type NonNullableKeys<T> = {
  [K in keyof T]: NonNullable<T[K]> extends T[K] ? K : never
}[keyof T];

type NonNullableProperties<T> = Pick<T, NonNullableKeys<T>>;

interface Example {
  name: string;
  age?: number;
  email: string | null;
}

type NonNullableExample = NonNullableProperties<Example>;
// { name: string; }
```

#### 3.2.2 高级条件类型
```typescript
// 递归条件类型
type DeepReadonly<T> = 
  T extends object ? {
    readonly [P in keyof T]: T[P] extends Function ? T[P] : DeepReadonly<T[P]>
  } : T;

// 条件类型与模板字面量类型
type CamelCase<S extends string> = 
  S extends `${infer P1}_${infer P2}${infer P3}`
    ? `${P1}${Uppercase<P2>}${CamelCase<P3>}`
    : S;

type TestCamelCase = CamelCase<"hello_world_test">; // "helloWorldTest"

// 条件类型用于函数重载
type Overload<T> = T extends {
  (...args: any[]): any;
  (...args: any[]): any;
} ? T : never;

// 复杂的类型推断
type PromiseValue<T> = T extends Promise<infer U> ? U : T;
type AsyncFunction<T> = T extends (...args: any[]) => Promise<infer U> ? U : never;

type AsyncFuncReturn = AsyncFunction<() => Promise<string>>; // string

// 条件类型与联合类型
type Filter<T, U> = T extends U ? T : never;

type FilterStrings = Filter<string | number | boolean, string>; // string

// 条件类型用于类型守卫
function isType<T, U>(value: T, guard: (value: any) => value is U): value is U {
  return guard(value);
}

// 条件类型与索引类型
type ArrayElement<T> = T extends readonly (infer U)[] ? U : never;

type StringArrayElement = ArrayElement<string[]>; // string
type ReadonlyArrayElement = ArrayElement<readonly number[]>; // number

// 条件类型与构造函数类型
type ConstructorParameters<T extends abstract new (...args: any) => any> = 
  T extends abstract new (...args: infer P) => any ? P : never;

class Person {
  constructor(public name: string, public age: number) {}
}

type PersonConstructorParams = ConstructorParameters<typeof Person>; // [string, number]

// 条件类型与实例类型
type InstanceType<T extends abstract new (...args: any) => any> = 
  T extends abstract new (...args: any) => infer R ? R : any;

type PersonInstance = InstanceType<typeof Person>; // Person

// 条件类型与this类型
type ThisParameterType<T> = T extends (this: infer U, ...args: any[]) => any ? U : unknown;

type OmitThisParameter<T> = T extends (this: any, ...args: infer P) => infer R 
  ? (...args: P) => R 
  : T;

function toHex(this: Number) {
  return this.toString(16);
}

type ToHexThisType = ThisParameterType<typeof toHex>; // Number
type ToHexWithoutThis = OmitThisParameter<typeof toHex>; // () => string
```

## 4. 类型体操和实践

### 4.1 类型体操练习

#### 4.1.1 常见类型体操
```typescript
// 1. 实现Pick
type MyPick<T, K extends keyof T> = {
  [P in K]: T[P];
};

// 2. 实现Omit
type MyOmit<T, K extends keyof T> = {
  [P in keyof T as P extends K ? never : P]: T[P];
};

// 3. 实现Readonly
type MyReadonly<T> = {
  readonly [P in keyof T]: T[P];
};

// 4. 实现Partial
type MyPartial<T> = {
  [P in keyof T]?: T[P];
};

// 5. 实现Required
type MyRequired<T> = {
  [P in keyof T]-?: T[P];
};

// 6. 实现Record
type MyRecord<K extends keyof any, T> = {
  [P in K]: T;
};

// 7. 实现Exclude
type MyExclude<T, U> = T extends U ? never : T;

// 8. 实现Extract
type MyExtract<T, U> = T extends U ? T : never;

// 9. 实现ReturnType
type MyReturnType<T> = T extends (...args: any[]) => infer R ? R : never;

// 10. 实现Parameters
type MyParameters<T> = T extends (...args: infer P) => any ? P : never;

// 高级类型体操

// 11. DeepReadonly
type DeepReadonly<T> = {
  readonly [P in keyof T]: T[P] extends object ? DeepReadonly<T[P]> : T[P];
};

// 12. UnionToIntersection
type UnionToIntersection<U> = 
  (U extends any ? (k: U) => void : never) extends (k: infer I) => void ? I : never;

// 13. GetOptional
type GetOptional<T> = {
  [K in keyof T as {} extends Pick<T, K> ? K : never]: T[K];
};

// 14. GetRequired
type GetRequired<T> = {
  [K in keyof T as {} extends Pick<T, K> ? never : K]: T[K];
};

// 15. CapitalizeWords
type CapitalizeWords<S extends string> = 
  S extends `${infer First} ${infer Rest}`
    ? `${Capitalize<First>} ${CapitalizeWords<Rest>}`
    : Capitalize<S>;

// 16. Replace
type Replace<S extends string, From extends string, To extends string> = 
  From extends "" 
    ? S 
    : S extends `${infer Prefix}${From}${infer Suffix}`
      ? `${Prefix}${To}${Suffix}`
      : S;

// 17. DropChar
type DropChar<S extends string, C extends string> = 
  S extends `${infer First}${infer Rest}`
    ? First extends C
      ? DropChar<Rest, C>
      : `${First}${DropChar<Rest, C>}`
    : S;

// 18. Palindrome
type Palindrome<T extends string> = 
  T extends `${infer First}${infer Rest}`
    ? Rest extends `${infer Middle}${First}`
      ? Palindrome<Middle>
      : false
    : true;

// 19. IsAny
type IsAny<T> = 0 extends (1 & T) ? true : false;

// 20. IsNever
type IsNever<T> = [T] extends [never] ? true : false;
```

#### 4.1.2 实际应用场景
```typescript
// API响应类型处理
type ApiResponse<T> = {
  data: T;
  status: number;
  message: string;
};

type SuccessResponse<T> = ApiResponse<T> & { status: 200 };
type ErrorResponse = ApiResponse<null> & { status: 400 | 401 | 403 | 404 | 500 };

// 表单验证类型
type ValidationRule<T> = {
  required?: boolean;
  minLength?: T extends string ? number : never;
  min?: T extends number ? number : never;
  pattern?: T extends string ? RegExp : never;
};

type FormValidation<T> = {
  [K in keyof T]: ValidationRule<T[K]>;
};

interface UserForm {
  name: string;
  age: number;
  email: string;
}

type UserFormValidation = FormValidation<UserForm>;

// 状态管理类型
type StateAction<T> = 
  | { type: "SET"; payload: T }
  | { type: "UPDATE"; payload: Partial<T> }
  | { type: "RESET" };

type StateReducer<T> = (state: T, action: StateAction<T>) => T;

// 配置对象类型
type ConfigSchema = {
  database: {
    host: string;
    port: number;
    credentials: {
      username: string;
      password: string;
    };
  };
  server: {
    port: number;
    host: string;
    ssl?: boolean;
  };
  features: {
    authentication: boolean;
    logging: boolean;
    caching: boolean;
  };
};

type ConfigPath = string; // 可以实现类型安全的路径访问

// 事件系统类型
type EventMap = {
  click: { x: number; y: number };
  keypress: { key: string; code: number };
  resize: { width: number; height: number };
};

type EventHandler<T extends keyof EventMap> = (event: EventMap[T]) => void;

type EventEmitter<T extends Record<string, any>> = {
  on<K extends keyof T>(event: K, handler: (data: T[K]) => void): void;
  off<K extends keyof T>(event: K, handler: (data: T[K]) => void): void;
  emit<K extends keyof T>(event: K, data: T[K]): void;
};

// 路由类型
type RouteParams<T extends string> = T extends `${string}:${infer Param}/${infer Rest}`
  ? { [K in Param | keyof RouteParams<Rest>]: string }
  : T extends `${string}:${infer Param}`
    ? { [K in Param]: string }
    : {};

type UserRouteParams = RouteParams<"users/:id/posts/:postId">;
// { id: string; postId: string; }
```

### 4.2 类型安全的实践模式

#### 4.2.1 类型守卫和谓词
```typescript
// 自定义类型守卫
function isString(value: unknown): value is string {
  return typeof value === "string";
}

function isNumber(value: unknown): value is number {
  return typeof value === "number" && !isNaN(value);
}

function isArray<T>(value: unknown): value is T[] {
  return Array.isArray(value);
}

function hasProperty<T extends object, K extends string>(
  obj: T,
  prop: K
): obj is T & Record<K, unknown> {
  return prop in obj;
}

// 联合类型判别
interface Cat {
  type: "cat";
  meow(): void;
}

interface Dog {
  type: "dog";
  bark(): void;
}

type Animal = Cat | Dog;

function handleAnimal(animal: Animal) {
  if (animal.type === "cat") {
    animal.meow(); // TypeScript知道这是Cat
  } else {
    animal.bark(); // TypeScript知道这是Dog
  }
}

// 更复杂的类型守卫
function isCat(animal: Animal): animal is Cat {
  return animal.type === "cat";
}

function processAnimal(animal: Animal) {
  if (isCat(animal)) {
    animal.meow();
  }
}

// 谓词函数用于数组过滤
const numbers: (string | number)[] = [1, "two", 3, "four"];
const onlyNumbers = numbers.filter((item): item is number => typeof item === "number");

// 对象形状类型守卫
interface User {
  name: string;
  email: string;
}

interface Admin {
  name: string;
  permissions: string[];
}

type Person = User | Admin;

function isAdmin(person: Person): person is Admin {
  return "permissions" in person;
}

function getPermissions(person: Person): string[] {
  if (isAdmin(person)) {
    return person.permissions;
  }
  return [];
}

// 枚举类型守卫
enum Status {
  Pending = "pending",
  Fulfilled = "fulfilled",
  Rejected = "rejected"
}

function isPending(status: Status): status is Status.Pending {
  return status === Status.Pending;
}

// 模板字面量类型守卫
type EventName = `on${Capitalize<string>}`;

function isEventName(name: string): name is EventName {
  return /^on[A-Z]/.test(name);
}
```

#### 4.2.2 类型安全的工厂模式
```typescript
// 类型安全的工厂函数
interface Shape {
  kind: string;
  area(): number;
  perimeter(): number;
}

class Circle implements Shape {
  kind = "circle";
  constructor(public radius: number) {}
  
  area(): number {
    return Math.PI * this.radius ** 2;
  }
  
  perimeter(): number {
    return 2 * Math.PI * this.radius;
  }
}

class Rectangle implements Shape {
  kind = "rectangle";
  constructor(public width: number, public height: number) {}
  
  area(): number {
    return this.width * this.height;
  }
  
  perimeter(): number {
    return 2 * (this.width + this.height);
  }
}

type ShapeType = "circle" | "rectangle";

type ShapeConfig<T extends ShapeType> = T extends "circle"
  ? { kind: T; radius: number }
  : T extends "rectangle"
    ? { kind: T; width: number; height: number }
    : never;

class ShapeFactory {
  static create<T extends ShapeType>(config: ShapeConfig<T>): Shape {
    switch (config.kind) {
      case "circle":
        return new Circle(config.radius);
      case "rectangle":
        return new Rectangle(config.width, config.height);
      default:
        throw new Error(`Unknown shape kind: ${config}`);
    }
  }
}

// 使用示例
const circle = ShapeFactory.create({ kind: "circle", radius: 5 });
const rectangle = ShapeFactory.create({ kind: "rectangle", width: 10, height: 20 });

// 类型安全的构建器模式
class QueryBuilder<T = any> {
  private query: string = "";
  
  select<K extends keyof T>(...columns: K[]): QueryBuilder<Pick<T, K>> {
    this.query += `SELECT ${columns.join(", ")}`;
    return this as any;
  }
  
  from(table: string): this {
    this.query += ` FROM ${table}`;
    return this;
  }
  
  where(condition: string): this {
    this.query += ` WHERE ${condition}`;
    return this;
  }
  
  build(): string {
    return this.query;
  }
}

interface User {
  id: number;
  name: string;
  email: string;
}

const query = new QueryBuilder<User>()
  .select("name", "email")
  .from("users")
  .where("id > 0")
  .build();

// 类型安全的装饰器
type Constructor<T = {}> = new (...args: any[]) => T;

function Timestamped<T extends Constructor>(Base: T) {
  return class extends Base {
    timestamp = Date.now();
  };
}

function Entity<T extends Constructor>(Base: T) {
  return class extends Base {
    id = Math.random().toString(36);
  };
}

@Timestamped
@Entity
class User {
  constructor(public name: string) {}
}

const user = new User("Alice");
console.log(user.id); // 随机ID
console.log(user.timestamp); // 时间戳
console.log(user.name); // Alice
```

## 5. TypeScript高级特性

### 5.1 装饰器和元数据

#### 5.1.1 装饰器基础
装饰器是一种特殊类型的声明，可以附加到类声明、方法、访问器、属性或参数上。

```typescript
// 启用装饰器（需要experimentalDecorators和emitDecoratorMetadata）
// tsconfig.json:
// {
//   "experimentalDecorators": true,
//   "emitDecoratorMetadata": true
// }

// 类装饰器
function sealed(constructor: Function) {
  Object.seal(constructor);
  Object.seal(constructor.prototype);
}

@sealed
class Greeter {
  greeting: string;
  
  constructor(message: string) {
    this.greeting = message;
  }
  
  greet() {
    return "Hello, " + this.greeting;
  }
}

// 类装饰器工厂
function classDecorator<T extends { new(...args: any[]): {} }>(constructor: T) {
  return class extends constructor {
    newProperty = "new property";
    hello = "override";
  };
}

@classDecorator
class Greeter2 {
  property = "original property";
  
  hello: string;
  
  constructor(m: string) {
    this.hello = m;
  }
}

// 方法装饰器
function enumerable(value: boolean) {
  return function(target: any, propertyKey: string, descriptor: PropertyDescriptor) {
    descriptor.enumerable = value;
  };
}

class Greeter3 {
  greeting: string;
  
  constructor(message: string) {
    this.greeting = message;
  }
  
  @enumerable(false)
  greet() {
    return "Hello, " + this.greeting;
  }
}

// 访问器装饰器
function configurable(value: boolean) {
  return function(target: any, propertyKey: string, descriptor: PropertyDescriptor) {
    descriptor.configurable = value;
  };
}

class Point {
  private _x: number;
  private _y: number;
  
  constructor(x: number, y: number) {
    this._x = x;
    this._y = y;
  }
  
  @configurable(false)
  get x() {
    return this._x;
  }
  
  @configurable(false)
  get y() {
    return this._y;
  }
}

// 属性装饰器
function format(formatString: string) {
  return function(target: any, propertyKey: string) {
    let value = target[propertyKey];
    
    const getter = function() {
      return `${formatString} ${value}`;
    };
    
    const setter = function(newVal: string) {
      value = newVal;
    };
    
    Object.defineProperty(target, propertyKey, {
      get: getter,
      set: setter,
      enumerable: true,
      configurable: true
    });
  };
}

class Greeter4 {
  @format("Hello,")
  greeting: string;
}

// 参数装饰器
function required(target: Object, propertyKey: string | symbol, parameterIndex: number) {
  const existingRequiredParameters = Reflect.getMetadata("required", target, propertyKey) || [];
  existingRequiredParameters.push(parameterIndex);
  Reflect.defineMetadata("required", existingRequiredParameters, target, propertyKey);
}

function validate(target: any, propertyKey: string, descriptor: PropertyDescriptor) {
  const originalMethod = descriptor.value;
  
  descriptor.value = function(...args: any[]) {
    const requiredParameters = Reflect.getMetadata("required", target, propertyKey) || [];
    
    for (const parameterIndex of requiredParameters) {
      if (args[parameterIndex] === undefined) {
        throw new Error(`Missing required argument at position ${parameterIndex}`);
      }
    }
    
    return originalMethod.apply(this, args);
  };
}

class Greeter5 {
  @validate
  greet(@required name: string) {
    return "Hello " + name;
  }
}
```

#### 5.1.2 反射和元数据
```typescript
// 使用reflect-metadata库
import "reflect-metadata";

// 自定义元数据键
const METADATA_KEY = {
  ROUTE: "route",
  VALIDATION: "validation"
};

// 路由装饰器
function Get(path: string) {
  return function(target: any, propertyKey: string, descriptor: PropertyDescriptor) {
    Reflect.defineMetadata(METADATA_KEY.ROUTE, { method: "GET", path }, target, propertyKey);
  };
}

function Post(path: string) {
  return function(target: any, propertyKey: string, descriptor: PropertyDescriptor) {
    Reflect.defineMetadata(METADATA_KEY.ROUTE, { method: "POST", path }, target, propertyKey);
  };
}

// 验证装饰器
function Validate(validationRules: any) {
  return function(target: any, propertyKey: string, descriptor: PropertyDescriptor) {
    Reflect.defineMetadata(METADATA_KEY.VALIDATION, validationRules, target, propertyKey);
  };
}

// 控制器类
class UserController {
  @Get("/users/:id")
  getUser(@required id: string) {
    return { id, name: "User " + id };
  }
  
  @Post("/users")
  @Validate({
    name: { required: true, type: "string" },
    email: { required: true, type: "email" }
  })
  createUser(user: any) {
    return { ...user, id: Date.now().toString() };
  }
}

// 元数据读取工具
function getRouteMetadata(target: any, propertyKey: string) {
  return Reflect.getMetadata(METADATA_KEY.ROUTE, target, propertyKey);
}

function getValidationMetadata(target: any, propertyKey: string) {
  return Reflect.getMetadata(METADATA_KEY.VALIDATION, target, propertyKey);
}

// 类型信息反射
function getType(target: any, propertyKey: string) {
  return Reflect.getMetadata("design:type", target, propertyKey);
}

class Example {
  name: string;
  age: number;
  active: boolean;
}

// 获取属性类型信息
const nameType = getType(Example.prototype, "name"); // String
const ageType = getType(Example.prototype, "age"); // Number
const activeType = getType(Example.prototype, "active"); // Boolean

// 自定义元数据装饰器
function Entity(tableName: string) {
  return function(target: Function) {
    Reflect.defineMetadata("tableName", tableName, target);
  };
}

function Column(columnName: string) {
  return function(target: any, propertyKey: string) {
    Reflect.defineMetadata("columnName", columnName, target, propertyKey);
  };
}

@Entity("users")
class UserEntity {
  @Column("user_name")
  name: string;
  
  @Column("user_email")
  email: string;
}

// ORM示例
class ORM {
  static getTableName(entity: Function): string {
    return Reflect.getMetadata("tableName", entity);
  }
  
  static getColumnName(entity: any, property: string): string {
    return Reflect.getMetadata("columnName", entity, property) || property;
  }
  
  static serialize(entity: any): any {
    const result: any = {};
    const prototype = Object.getPrototypeOf(entity);
    
    Object.keys(entity).forEach(key => {
      const columnName = this.getColumnName(prototype, key);
      result[columnName] = entity[key];
    });
    
    return result;
  }
}

const user = new UserEntity();
user.name = "John";
user.email = "john@example.com";

const serialized = ORM.serialize(user);
// { user_name: "John", user_email: "john@example.com" }
```

### 5.2 模块和命名空间

#### 5.2.1 模块系统
```typescript
// 导出和导入
// math.ts
export const PI = 3.14159;
export function add(a: number, b: number): number {
  return a + b;
}
export function subtract(a: number, b: number): number {
  return a - b;
}

// 默认导出
export default class Calculator {
  add(a: number, b: number): number {
    return a + b;
  }
}

// 重新导出
export * from "./utils";
export { add as sum } from "./math";

// 导入
// main.ts
import Calculator, { PI, add, subtract } from "./math";
import * as Math from "./math";
import { add as sum } from "./math";

// 动态导入
async function loadModule() {
  const module = await import("./math");
  console.log(module.PI);
  const result = module.add(5, 3);
  return result;
}

// 类型导入
import type { User } from "./types";
import type { ApiResponse } from "./api";

// 命名空间（旧式模块）
namespace Validation {
  export interface StringValidator {
    isAcceptable(s: string): boolean;
  }
  
  const lettersRegexp = /^[A-Za-z]+$/;
  const numberRegexp = /^[0-9]+$/;
  
  export class LettersOnlyValidator implements StringValidator {
    isAcceptable(s: string) {
      return lettersRegexp.test(s);
    }
  }
  
  export class ZipCodeValidator implements StringValidator {
    isAcceptable(s: string) {
      return s.length === 5 && numberRegexp.test(s);
    }
  }
}

// 使用命名空间
let validators: { [s: string]: Validation.StringValidator; } = {};
validators["ZIP code"] = new Validation.ZipCodeValidator();
validators["Letters only"] = new Validation.LettersOnlyValidator();

// 嵌套命名空间
namespace Shapes {
  export namespace Polygons {
    export class Triangle {}
    export class Square {}
  }
}

let triangle = new Shapes.Polygons.Triangle();

// 命名空间与模块结合
// shapes.ts
export namespace Shapes {
  export class Triangle {
    constructor(public sides: number) {}
  }
}

// 使用
import { Shapes } from "./shapes";
const triangle = new Shapes.Triangle(3);

// 模块解析策略
// 相对路径：./module, ../module
// 绝对路径：/module, module
// node_modules查找

// 模块声明
declare module "jquery" {
  export interface JQueryStatic {
    (selector: string): JQuery;
    fn: any;
  }
  
  export interface JQuery {
    html(): string;
    html(content: string): JQuery;
  }
  
  export const $: JQueryStatic;
}

// 声明合并
// 扩展现有模块
declare module "express" {
  interface Request {
    user?: User;
  }
}

// 全局声明
declare global {
  interface Window {
    myCustomProperty: string;
  }
}

// 模块增强
// utils.ts
export function formatDate(date: Date): string {
  return date.toISOString();
}

// utils-enhancement.ts
import "./utils";
declare module "./utils" {
  function formatDate(date: Date, format: string): string;
}
```

#### 5.2.2 高级模块模式
```typescript
// 模块工厂模式
interface ModuleFactory<T> {
  create(): T;
  destroy(instance: T): void;
}

class DatabaseModuleFactory implements ModuleFactory<Database> {
  create(): Database {
    return new Database();
  }
  
  destroy(instance: Database): void {
    instance.close();
  }
}

// 依赖注入容器
class DIContainer {
  private services = new Map<string, any>();
  private factories = new Map<string, () => any>();
  
  register<T>(name: string, factory: () => T): void {
    this.factories.set(name, factory);
  }
  
  registerInstance<T>(name: string, instance: T): void {
    this.services.set(name, instance);
  }
  
  resolve<T>(name: string): T {
    if (this.services.has(name)) {
      return this.services.get(name);
    }
    
    const factory = this.factories.get(name);
    if (!factory) {
      throw new Error(`Service ${name} not found`);
    }
    
    const instance = factory();
    this.services.set(name, instance);
    return instance;
  }
}

// 模块加载器
class ModuleLoader {
  private loadedModules = new Set<string>();
  private moduleCache = new Map<string, any>();
  
  async load(moduleName: string): Promise<any> {
    if (this.loadedModules.has(moduleName)) {
      return this.moduleCache.get(moduleName);
    }
    
    const module = await import(`./modules/${moduleName}`);
    this.loadedModules.add(moduleName);
    this.moduleCache.set(moduleName, module);
    
    return module;
  }
  
  async loadDependencies(dependencies: string[]): Promise<any[]> {
    return Promise.all(dependencies.map(dep => this.load(dep)));
  }
}

// 插件系统
interface Plugin {
  name: string;
  version: string;
  initialize(): void;
  destroy(): void;
}

class PluginManager {
  private plugins = new Map<string, Plugin>();
  
  async loadPlugin(pluginPath: string): Promise<void> {
    const pluginModule = await import(pluginPath);
    const plugin: Plugin = new pluginModule.default();
    
    if (this.plugins.has(plugin.name)) {
      throw new Error(`Plugin ${plugin.name} already loaded`);
    }
    
    plugin.initialize();
    this.plugins.set(plugin.name, plugin);
  }
  
  unloadPlugin(name: string): void {
    const plugin = this.plugins.get(name);
    if (plugin) {
      plugin.destroy();
      this.plugins.delete(name);
    }
  }
  
  getPlugin<T extends Plugin>(name: string): T | undefined {
    return this.plugins.get(name) as T;
  }
}

// 模块配置系统
interface ModuleConfig {
  enabled: boolean;
  options: Record<string, any>;
}

class ConfigManager {
  private configs = new Map<string, ModuleConfig>();
  
  setModuleConfig(moduleName: string, config: ModuleConfig): void {
    this.configs.set(moduleName, config);
  }
  
  getModuleConfig(moduleName: string): ModuleConfig | undefined {
    return this.configs.get(moduleName);
  }
  
  isModuleEnabled(moduleName: string): boolean {
    const config = this.configs.get(moduleName);
    return config?.enabled ?? false;
  }
}

// 条件模块加载
class ConditionalModuleLoader {
  async loadIfEnabled(moduleName: string, configManager: ConfigManager): Promise<any> {
    if (configManager.isModuleEnabled(moduleName)) {
      const module = await import(`./modules/${moduleName}`);
      const config = configManager.getModuleConfig(moduleName);
      return module.default(config?.options);
    }
    return null;
  }
}
```

## 6. TypeScript最佳实践

### 6.1 项目配置和架构

#### 6.1.1 tsconfig.json配置
```json
{
  "compilerOptions": {
    // 基础选项
    "target": "ES2020",                    // 编译目标版本
    "module": "commonjs",                  // 模块系统
    "lib": ["ES2020", "DOM"],              // 包含的库文件
    "outDir": "./dist",                    // 输出目录
    "rootDir": "./src",                    // 根目录
    
    // 严格检查
    "strict": true,                        // 启用所有严格类型检查
    "noImplicitAny": true,                 // 禁止隐式any类型
    "strictNullChecks": true,              // 严格的null检查
    "strictFunctionTypes": true,           // 严格的函数类型
    "strictBindCallApply": true,           // 严格的bind/call/apply检查
    "strictPropertyInitialization": true,  // 严格的属性初始化检查
    "noImplicitThis": true,                // 禁止隐式this类型
    "noImplicitReturns": true,             // 函数必须有返回值
    "noFallthroughCasesInSwitch": true,    // switch语句必须有break
    "noUncheckedIndexedAccess": true,      // 索引访问严格检查
    
    // 模块解析
    "moduleResolution": "node",            // 模块解析策略
    "baseUrl": "./",                       // 基础URL
    "paths": {                             // 路径映射
      "@/*": ["src/*"],
      "@/components/*": ["src/components/*"],
      "@/utils/*": ["src/utils/*"]
    },
    "esModuleInterop": true,               // ES模块互操作
    "allowSyntheticDefaultImports": true,  // 允许合成默认导入
    "resolveJsonModule": true,             // 解析JSON模块
    
    // 代码生成
    "declaration": true,                   // 生成声明文件
    "declarationMap": true,                // 生成声明映射文件
    "sourceMap": true,                     // 生成源映射文件
    "removeComments": false,               // 保留注释
    "importHelpers": true,                 // 导入tslib帮助函数
    "downlevelIteration": true,            // 降级迭代器支持
    
    // 高级选项
    "experimentalDecorators": true,        // 实验性装饰器
    "emitDecoratorMetadata": true,         // 装饰器元数据
    "skipLibCheck": true,                  // 跳过库文件检查
    "forceConsistentCasingInFileNames": true, // 强制文件名大小写一致
    
    // 类型检查
    "noUnusedLocals": true,                // 检查未使用的局部变量
    "noUnusedParameters": true,            // 检查未使用的参数
    "exactOptionalPropertyTypes": true,    // 精确的可选属性类型
    "noImplicitOverride": true,            // 隐式重写检查
    
    // 其他
    "incremental": true,                   // 增量编译
    "tsBuildInfoFile": "./dist/.tsbuildinfo"
  },
  "include": [
    "src/**/*"
  ],
  "exclude": [
    "node_modules",
    "dist",
    "**/*.test.ts",
    "**/*.spec.ts"
  ],
  "references": [
    { "path": "./packages/common" },
    { "path": "./packages/server" },
    { "path": "./packages/client" }
  ]
}
```

#### 6.1.2 项目结构最佳实践
```
project/
├── src/
│   ├── components/          # 组件
│   │   ├── common/         # 通用组件
│   │   ├── forms/          # 表单组件
│   │   └── index.ts        # 导出文件
│   ├── services/           # 服务层
│   │   ├── api/            # API服务
│   │   ├── auth/           # 认证服务
│   │   └── index.ts
│   ├── types/              # 类型定义
│   │   ├── api.ts          # API类型
│   │   ├── user.ts         # 用户类型
│   │   └── index.ts
│   ├── utils/              # 工具函数
│   │   ├── helpers.ts      # 辅助函数
│   │   ├── validators.ts   # 验证函数
│   │   └── index.ts
│   ├── hooks/              # 自定义Hook
│   │   ├── useAuth.ts
│   │   └── index.ts
│   ├── constants/          # 常量
│   │   ├── api.ts
│   │   └── index.ts
│   ├── store/              # 状态管理
│   │   ├── slices/
│   │   └── index.ts
│   └── index.ts            # 入口文件
├── tests/                  # 测试文件
├── types/                  # 全局类型定义
├── docs/                   # 文档
├── package.json
├── tsconfig.json
├── tsconfig.build.json
└── README.md
```

### 6.2 代码质量和规范

#### 6.2.1 ESLint和Prettier配置
```json
// .eslintrc.json
{
  "extends": [
    "@typescript-eslint/recommended",
    "@typescript-eslint/recommended-requiring-type-checking",
    "prettier"
  ],
  "parser": "@typescript-eslint/parser",
  "parserOptions": {
    "ecmaVersion": 2020,
    "sourceType": "module",
    "project": "./tsconfig.json"
  },
  "plugins": ["@typescript-eslint"],
  "rules": {
    "@typescript-eslint/no-unused-vars": "error",
    "@typescript-eslint/no-explicit-any": "warn",
    "@typescript-eslint/explicit-function-return-type": "warn",
    "@typescript-eslint/no-non-null-assertion": "warn",
    "@typescript-eslint/prefer-const": "error",
    "@typescript-eslint/no-var-requires": "error",
    "@typescript-eslint/ban-ts-comment": "warn",
    "@typescript-eslint/no-empty-function": "warn",
    "@typescript-eslint/prefer-nullish-coalescing": "error",
    "@typescript-eslint/prefer-optional-chain": "error",
    "@typescript-eslint/strict-boolean-expressions": "error"
  },
  "env": {
    "browser": true,
    "node": true,
    "es6": true
  }
}
```

```json
// .prettierrc
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 80,
  "tabWidth": 2,
  "useTabs": false,
  "bracketSpacing": true,
  "arrowParens": "avoid"
}
```

#### 6.2.2 类型安全编程规范
```typescript
// 1. 避免使用any，使用unknown或具体类型
function processValue(value: unknown) {
  if (typeof value === "string") {
    return value.toUpperCase();
  }
  throw new Error("Value must be a string");
}

// 2. 使用类型守卫
function isUser(obj: unknown): obj is User {
  return (
    typeof obj === "object" &&
    obj !== null &&
    "name" in obj &&
    "email" in obj &&
    typeof (obj as any).name === "string" &&
    typeof (obj as any).email === "string"
  );
}

// 3. 使用readonly保护不可变数据
interface Config {
  readonly apiUrl: string;
  readonly timeout: number;
}

// 4. 使用as const创建字面量类型
const themes = ["light", "dark"] as const;
type Theme = typeof themes[number]; // "light" | "dark"

// 5. 使用satisfies操作符
const config = {
  apiUrl: "https://api.example.com",
  timeout: 5000
} satisfies Config;

// 6. 使用模板字面量类型
type EventName = `on${Capitalize<string>}`;
type EventHandler<T> = (event: T) => void;

// 7. 使用品牌类型防止类型混淆
type UserId = string & { readonly brand: unique symbol };
type ProductId = string & { readonly brand: unique symbol };

function createUserId(id: string): UserId {
  return id as UserId;
}

function createProductId(id: string): ProductId {
  return id as ProductId;
}

// 8. 使用函数重载提供更好的类型推断
function createElement(tag: "div"): HTMLDivElement;
function createElement(tag: "span"): HTMLSpanElement;
function createElement(tag: string): HTMLElement {
  return document.createElement(tag);
}

// 9. 使用条件类型创建灵活的API
type ApiResponse<T> = 
  T extends string ? { message: T } :
  T extends number ? { value: T } :
  { data: T };

// 10. 使用映射类型创建派生类型
type Optional<T, K extends keyof T> = Omit<T, K> & Partial<Pick<T, K>>;

// 11. 使用断言函数
function assertIsString(value: unknown): asserts value is string {
  if (typeof value !== "string") {
    throw new Error("Expected string");
  }
}

// 12. 使用类型谓词进行类型过滤
function filterStrings(items: unknown[]): string[] {
  return items.filter((item): item is string => typeof item === "string");
}

// 13. 使用泛型约束确保类型安全
interface Repository<T extends { id: string }> {
  findById(id: string): Promise<T | null>;
  save(entity: T): Promise<T>;
}

// 14. 使用工具类型简化类型操作
type UserUpdate = Partial<Pick<User, "name" | "email">>;
type UserWithoutSensitive = Omit<User, "password" | "token">;

// 15. 使用类型工厂创建复杂的类型
type Entity<T> = T & {
  id: string;
  createdAt: Date;
  updatedAt: Date;
};

function createEntity<T>(data: T): Entity<T> {
  return {
    ...data,
    id: generateId(),
    createdAt: new Date(),
    updatedAt: new Date()
  };
}
```

## 7. 总结

TypeScript的类型系统是其最强大的特性，为JavaScript开发提供了静态类型检查和现代编程语言特性。通过深入学习TypeScript的类型系统，开发者可以编写更安全、更可维护的代码。

### 7.1 关键要点
1. **基础类型**: 掌握原始类型、接口、类型别名
2. **高级类型**: 理解泛型、联合类型、交叉类型
3. **类型操作**: 熟练使用映射类型、条件类型
4. **类型体操**: 通过练习掌握复杂类型操作
5. **实践模式**: 应用类型安全的编程模式
6. **高级特性**: 掌握装饰器、模块系统
7. **最佳实践**: 遵循代码质量和规范标准

### 7.2 学习路径
1. **基础阶段**: 类型注解、接口、基础泛型
2. **进阶阶段**: 高级类型、类型操作、类型体操
3. **高级阶段**: 装饰器、元数据、模块系统
4. **实践阶段**: 项目架构、最佳实践、性能优化

### 7.3 实践建议
1. **渐进式采用**: 从小项目开始，逐步增加类型复杂度
2. **严格模式**: 启用所有严格类型检查选项
3. **类型优先**: 先设计类型，再实现逻辑
4. **工具利用**: 充分利用IDE的类型提示和检查功能
5. **持续学习**: 跟随TypeScript版本更新，学习新特性

TypeScript的类型系统是一个强大而复杂的工具，掌握它需要持续的实践和学习。通过类型安全的编程实践，可以显著提高代码质量和开发效率。
