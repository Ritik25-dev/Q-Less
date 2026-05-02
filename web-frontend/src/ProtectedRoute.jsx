import { useContext } from "react"
import { AuthContext } from "./App"
import { Navigate, Outlet } from "react-router-dom"

export const AdminRoute = () => {
    const { role ,isLoading} = useContext(AuthContext)
    if (isLoading) return null;
    return role === 'Admin' ? <Outlet /> : <Navigate to="/" replace />
}

export const SharedRoute = () => {
    const { role ,isLoading} = useContext(AuthContext);
    if (isLoading) return null;
    const isAuthorized = role === 'Admin' || role === 'Staff';
    return isAuthorized ? <Outlet /> : <Navigate to="/" replace />;
};
