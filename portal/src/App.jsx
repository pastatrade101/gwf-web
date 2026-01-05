import React, { useEffect, useMemo, useState } from "react";
import { initializeApp } from "firebase/app";
import {
  getAuth,
  onAuthStateChanged,
  signInWithEmailAndPassword,
  createUserWithEmailAndPassword,
  signOut,
} from "firebase/auth";
import { firebaseConfig, getConfigErrors } from "./config.js";
import { dataConnectRequest, QUERIES } from "./dataConnect.js";

export default function App() {
  const configErrors = getConfigErrors();
  if (configErrors.length) {
    return (
      <div className="page">
        <div className="auth-card">
          <header>
            <h1>Portal Configuration Required</h1>
            <p>Set the missing values in <code>portal/.env</code> then restart the server.</p>
          </header>
          <div className="alert error">
            <ul>
              {configErrors.map((err) => (
                <li key={err}>{err}</li>
              ))}
            </ul>
          </div>
        </div>
      </div>
    );
  }

  const app = initializeApp(firebaseConfig);
  const auth = getAuth(app);

  const [user, setUser] = useState(null);
  const [mode, setMode] = useState("login");
  const [authError, setAuthError] = useState("");
  const [authBusy, setAuthBusy] = useState(false);

  const [departments, setDepartments] = useState([]);
  const [services, setServices] = useState([]);
  const [dataError, setDataError] = useState("");
  const [loadingData, setLoadingData] = useState(false);

  const [form, setForm] = useState({
    name: "",
    description: "",
    requirements: "",
    onlineLink: "",
    contactInfo: "",
    departmentId: "",
  });
  const [departmentForm, setDepartmentForm] = useState({
    name: "",
    contactEmail: "",
    website: "",
    address: "",
    phoneNumber: "",
  });

  useEffect(() => {
    return onAuthStateChanged(auth, (next) => setUser(next));
  }, []);

  useEffect(() => {
    if (!user) return;
    void loadData();
  }, [user]);

  const hasDepartments = departments.length > 0;
  const canSubmit = useMemo(() => {
    return (
      form.name.trim() &&
      form.description.trim() &&
      form.departmentId.trim() &&
      !loadingData
    );
  }, [form, loadingData]);
  const canCreateDepartment = useMemo(() => {
    return (
      departmentForm.name.trim() &&
      departmentForm.contactEmail.trim() &&
      !loadingData
    );
  }, [departmentForm, loadingData]);

  async function loadData() {
    setLoadingData(true);
    setDataError("");
    try {
      const token = await user.getIdToken();
      const [deptData, svcData] = await Promise.all([
        dataConnectRequest({
          query: QUERIES.listDepartments,
          variables: {},
          token,
        }),
        dataConnectRequest({
          query: QUERIES.listServices,
          variables: {},
          token,
        }),
      ]);
      setDepartments(deptData.departments ?? []);
      setServices(svcData.services ?? []);
      if (!form.departmentId && deptData.departments?.length) {
        setForm((prev) => ({
          ...prev,
          departmentId: deptData.departments[0].id,
        }));
      }
    } catch (err) {
      setDataError(err.message);
    } finally {
      setLoadingData(false);
    }
  }

  async function handleAuthSubmit(e) {
    e.preventDefault();
    setAuthBusy(true);
    setAuthError("");
    const email = e.target.email.value.trim();
    const password = e.target.password.value.trim();
    try {
      if (mode === "login") {
        await signInWithEmailAndPassword(auth, email, password);
      } else {
        await createUserWithEmailAndPassword(auth, email, password);
      }
    } catch (err) {
      setAuthError(err.message);
    } finally {
      setAuthBusy(false);
    }
  }

  async function handleCreateService(e) {
    e.preventDefault();
    setLoadingData(true);
    setDataError("");
    try {
      const token = await user.getIdToken();
      await dataConnectRequest({
        query: QUERIES.createService,
        variables: {
          name: form.name.trim(),
          description: form.description.trim(),
          requirements: form.requirements.trim() || null,
          onlineLink: form.onlineLink.trim() || null,
          contactInfo: form.contactInfo.trim() || null,
          departmentId: form.departmentId.trim(),
        },
        token,
      });
      setForm((prev) => ({
        ...prev,
        name: "",
        description: "",
        requirements: "",
        onlineLink: "",
        contactInfo: "",
      }));
      await loadData();
    } catch (err) {
      setDataError(err.message);
    } finally {
      setLoadingData(false);
    }
  }

  async function handleCreateDepartment(e) {
    e.preventDefault();
    setLoadingData(true);
    setDataError("");
    try {
      const token = await user.getIdToken();
      await dataConnectRequest({
        query: QUERIES.createDepartment,
        variables: {
          name: departmentForm.name.trim(),
          contactEmail: departmentForm.contactEmail.trim(),
          website: departmentForm.website.trim() || null,
          address: departmentForm.address.trim() || null,
          phoneNumber: departmentForm.phoneNumber.trim() || null,
        },
        token,
      });
      setDepartmentForm({
        name: "",
        contactEmail: "",
        website: "",
        address: "",
        phoneNumber: "",
      });
      await loadData();
    } catch (err) {
      setDataError(err.message);
    } finally {
      setLoadingData(false);
    }
  }

  if (!user) {
    return (
      <div className="page">
        <div className="auth-card">
          <header>
            <h1>TAMISEMI Services Portal</h1>
            <p>Official portal for managing government e-services.</p>
          </header>
          <form onSubmit={handleAuthSubmit}>
            <div className="field">
              <label>Email</label>
              <input name="email" type="email" required placeholder="name@tamisemi.go.tz" />
            </div>
            <div className="field">
              <label>Password</label>
              <input name="password" type="password" required placeholder="••••••••" />
            </div>
            {authError && <div className="alert error">{authError}</div>}
            <button className="primary" type="submit" disabled={authBusy}>
              {authBusy ? "Please wait..." : mode === "login" ? "Sign in" : "Create account"}
            </button>
          </form>
          <div className="switch">
            {mode === "login" ? (
              <button type="button" onClick={() => setMode("signup")}>
                Need an account? Sign up
              </button>
            ) : (
              <button type="button" onClick={() => setMode("login")}>
                Already have an account? Sign in
              </button>
            )}
          </div>
        </div>
      </div>
    );
  }

  return (
      <div className="portal">
      {dataError && <div className="alert error">{dataError}</div>}
      <header className="portal-header">
        <div>
          <h1>Services Directory Admin</h1>
          <p>Maintain official TAMISEMI and Local Government e-services.</p>
        </div>
        <div className="user-block">
          <span>{user.email}</span>
          <button onClick={() => signOut(auth)}>Sign out</button>
        </div>
      </header>

      <main className="portal-grid">
        <section className="card">
          <h2>Create Department</h2>
          <form onSubmit={handleCreateDepartment} className="service-form">
            <div className="field">
              <label>Department name</label>
              <input
                value={departmentForm.name}
                onChange={(e) =>
                  setDepartmentForm({ ...departmentForm, name: e.target.value })
                }
                placeholder="e.g. PO-RALG"
                required
              />
            </div>
            <div className="field">
              <label>Contact email</label>
              <input
                value={departmentForm.contactEmail}
                onChange={(e) =>
                  setDepartmentForm({
                    ...departmentForm,
                    contactEmail: e.target.value,
                  })
                }
                placeholder="info@tamisemi.go.tz"
                required
                type="email"
              />
            </div>
            <div className="field">
              <label>Website</label>
              <input
                value={departmentForm.website}
                onChange={(e) =>
                  setDepartmentForm({ ...departmentForm, website: e.target.value })
                }
                placeholder="https://tamisemi.go.tz"
              />
            </div>
            <div className="field">
              <label>Address</label>
              <input
                value={departmentForm.address}
                onChange={(e) =>
                  setDepartmentForm({ ...departmentForm, address: e.target.value })
                }
                placeholder="Dodoma"
              />
            </div>
            <div className="field">
              <label>Phone number</label>
              <input
                value={departmentForm.phoneNumber}
                onChange={(e) =>
                  setDepartmentForm({
                    ...departmentForm,
                    phoneNumber: e.target.value,
                  })
                }
                placeholder="+255 123 456 789"
              />
            </div>
            {dataError && <div className="alert error">{dataError}</div>}
            <button className="primary" type="submit" disabled={!canCreateDepartment}>
              {loadingData ? "Saving..." : "Save Department"}
            </button>
          </form>
        </section>

        <section className="card">
          <h2>Create Service</h2>
          <form onSubmit={handleCreateService} className="service-form">
            <div className="field">
              <label>Service name</label>
              <input
                value={form.name}
                onChange={(e) => setForm({ ...form, name: e.target.value })}
                placeholder="e.g. TAUSI"
                required
              />
            </div>
            <div className="field">
              <label>Description</label>
              <textarea
                rows="3"
                value={form.description}
                onChange={(e) => setForm({ ...form, description: e.target.value })}
                placeholder="Short summary for citizens."
                required
              />
            </div>
            <div className="field">
              <label>Department</label>
              <select
                value={form.departmentId}
                onChange={(e) => setForm({ ...form, departmentId: e.target.value })}
                required
                disabled={loadingData || !hasDepartments}
              >
                {!hasDepartments && (
                  <option value="">
                    {loadingData ? "Loading departments..." : "No departments available"}
                  </option>
                )}
                {hasDepartments && (
                  <option value="" disabled>
                    Select a department
                  </option>
                )}
                {departments.map((dept) => (
                  <option key={dept.id} value={dept.id}>
                    {dept.name}
                  </option>
                ))}
              </select>
            </div>
            <div className="field">
              <label>Requirements</label>
              <input
                value={form.requirements}
                onChange={(e) => setForm({ ...form, requirements: e.target.value })}
                placeholder="IDs, accounts, documents"
              />
            </div>
            <div className="field">
              <label>Online link</label>
              <input
                value={form.onlineLink}
                onChange={(e) => setForm({ ...form, onlineLink: e.target.value })}
                placeholder="https://service.go.tz"
              />
            </div>
            <div className="field">
              <label>Contact info</label>
              <input
                value={form.contactInfo}
                onChange={(e) => setForm({ ...form, contactInfo: e.target.value })}
                placeholder="support@tamisemi.go.tz"
              />
            </div>
            {dataError && <div className="alert error">{dataError}</div>}
            <button className="primary" type="submit" disabled={!canSubmit}>
              {loadingData ? "Saving..." : "Save Service"}
            </button>
          </form>
        </section>

        <section className="card">
          <div className="card-header">
            <h2>Existing Services</h2>
            <button onClick={loadData} disabled={loadingData}>
              Refresh
            </button>
          </div>
          {loadingData && <p className="muted">Loading services...</p>}
          <div className="service-list">
            {services.map((svc) => (
              <div className="service-item" key={svc.id}>
                <div>
                  <h3>{svc.name}</h3>
                  <p className="muted">{svc.description}</p>
                  <div className="meta">
                    <span>{svc.department?.name ?? "Unassigned"}</span>
                    {svc.onlineLink && <a href={svc.onlineLink}>{svc.onlineLink}</a>}
                  </div>
                </div>
              </div>
            ))}
            {!services.length && !loadingData && <p className="muted">No services yet.</p>}
          </div>
        </section>
      </main>
    </div>
  );
}
