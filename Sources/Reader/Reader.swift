public struct Reader<Env, T> {
    let r: (Env) -> T

    public init(_ r: @escaping (Env) -> T) {
        self.r = r
    }

    public func runReader(with env: Env) -> T {
        return r(env)
    }
}

public extension Reader {
    static func of(_ x: T) -> Reader<Env, T> {
        return Reader<Env, T>({ _ in  x })
    }

    func map<U>(_ transform: @escaping (T) -> U) -> Reader<Env, U> {
        return Reader<Env, U>({ transform(self.runReader(with: $0))})
    }
    
    func flatMap<U>(_ transform: @escaping (T) -> Reader<Env, U>) -> Reader<Env, U> {
        return Reader<Env, U>({ r in transform(self.runReader(with: r)).runReader(with: r) })
    }
    
    func ap<A, B>(_ x: Reader<Env, A>) -> Reader<Env, B> where T == (A) -> B {
        return Reader<Env, B>({ env in
            let fn = self.runReader(with: env)
            return x.map(fn).runReader(with: env)
        })
    }
}
