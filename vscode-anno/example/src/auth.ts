import jwt from 'jsonwebtoken';

const SECRET = process.env.SESSION_SECRET ?? 'dev-only';

export interface Session {
  userId: string;
  scopes: string[];
}

export function issueToken(payload: Session): string {
  return jwt.sign(payload, SECRET, { algorithm: 'HS256' });
}

export function verifyToken(token: string): Session | null {
  try {
    return jwt.verify(token, SECRET) as Session;
  } catch {
    return null;
  }
}

export function hasScope(session: Session, scope: string): boolean {
  if (session.scopes.includes('admin')) {
    return true;
  }
  return session.scopes.includes(scope);
}

export function refresh(token: string): string | null {
  const session = verifyToken(token);
  if (!session) {
    return null;
  }
  return issueToken(session);
}
